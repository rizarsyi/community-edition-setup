#!/usr/bin/python3

import json
import os
import threading
import time
import textwrap

from bottle import Bottle
from bottle import redirect
from bottle import template
from bottle import TEMPLATE_PATH
from bottle import request
from bottle import response
from distutils.util import strtobool
from queue import Queue
from messages import msg

template_path = os.path.abspath('./templates/web_setup')
TEMPLATE_PATH.insert(0, template_path)

# install types
NONE = 0
LOCAL = '1'
REMOTE = '2'

COMPLETED = -99
ERROR = -101

middleware = lambda functions: lambda caller: lambda *args, **kwargs: next(
    filter(None, map(lambda g: g(*args, **kwargs), functions)),
    caller(*args, **kwargs)
)


def has_body(*args, **kwargs):
    if not request.json:
        response.status = 400
        return {'error': 'ValidationError',
                'error_message': 'Body is required (and must be JSON).'}


def body_req(required):
    def inner(*args, **kwargs):
        data = {
            'status': True
        }

        errors = []
        for i in required:
            if request.forms.get(i) is None or request.forms.get(i) == '':
                errors.append({
                    'field': i, 'message': '{} is required.'.format(i)})

            if i == 'hostname' and request.forms.get(i) == 'localhost':
                errors.append({
                    'field': i, 'message': msg.enter_hostname_local})

        if errors:
            data.update({'status': False})
            data.update({'errors': errors})

        return dict(data)

    return inner


def validate_host(fields):
    def inner(*args, **kwargs):

        data = {
            'status': True
        }

        errors = []
        for i in fields:
            if request.forms.get(i) is None or request.forms.get(i) == '':
                errors.append({
                    'field': i, 'message': '{} is required.'.format(i)})

            if i == 'countryCode' and len(request.forms.get(i)) < 2:
                errors.append({
                    'field': i, 'message': msg.enter_valid_countryCode})

            if i == 'oxtrust_admin_password' and len(request.forms.get(i)) < 6:
                errors.append({
                    'field': i, 'message': msg.oxtrust_admin_password_warning})

        if errors:
            data.update({'status': False})
            data.update({'errors': errors})

        return dict(data)

    return inner


def validate_services(fields):
    def inner(*args, **kwargs):

        data = {
            'status': True
        }

        errors = []
        for i in fields:
            if request.forms.get(i) is None or request.forms.get(i) == '':
                errors.append({
                    'field': i, 'message': '{} is required.'.format(i)})

        if errors:
            data.update({'status': False})
            data.update({'errors': errors})

        return dict(data)

    return inner


class GluuSetupApp:
    def __init__(self):
        self._app = Bottle()
        self.host = '0.0.0.0'
        self.port = '8080'
        self._routes()
        self.exit_reason = str()
        self.my_counter = 0
        self.do_notify = True
        self.install_object = None
        self.queue = Queue()
        self.requirements = ('file_max', 'mem_size',
                             'number_of_cpu', 'free_disk_space')
        self._confirm_lisence = False
        self._myfields = ('lisence_confirm', 'ip', 'hostname',
                          'city', 'state', 'orgName', 'admin_email',
                          'countryCode', 'application_max_ram',
                          'oxtrust_admin_password', 'installHttpd',
                          'installSaml', 'installOxAuthRP',
                          'installPassport', 'installGluuRadius', 'installOxd',
                          'installCasa', 'oxd_url', 'wrends_install',
                          'wrends_password', 'wrends_hosts', 'cb_install',
                          'cb_admin', 'cb_password', 'cb_hosts')

    def start(self):
        self._app.run(host=self.host, port=self.port, debug=True)

    def _routes(self):
        self._app.route('/', ['GET', 'POST'], callback=self.wizard)
        self._app.route('/initialize', 'GET', callback=self.initialize)
        self._app.route('/install', callback=self.installation)
        self._app.route('/storage_selection', ['GET', 'POST'],
                        callback=self.storage_selection)
        self._app.route('/display_summary', ['GET', 'POST'],
                        callback=self.display_summary)
        self._app.route('/installation', ['GET'],
                        callback=self.install_handler)
        self._app.route('/post-installation', 'GET',
                        callback=self.post_install_handler)
        self._app.route('/add-services', 'POST',
                        callback=self.add_services_handler)
        self._app.route('/get-log', 'GET',
                        callback=self.get_log)
        self._app.route('/quit', ['GET', 'POST'],
                        callback=self.shutdown)

        self._app.route('/collect-data/<step>', 'POST',
                        callback=self.collect_data)
        self._app.route('/collect-system-info', 'POST',
                        callback=self.collect_system_info)
        self._app.route('/collect-host', 'POST', callback=self.collect_host)
        self._app.route('/collect-services', 'POST',
                        callback=self.collect_services)
        self._app.route('/collect-database', 'POST',
                        callback=self.collect_database)
        self._app.route('/populate-dbbackend', 'GET',
                        callback=self.populate_dbbackend)


    def initialize(self):
        if self.install_object.check_installed():
            return dict({'installed': True})

        fields = {}

        if not self.install_object.hostname:
            hostname = self.install_object.detect_hostname()
            self.install_object.hostname = hostname

        for k in self._myfields:
            value = getattr(self.install_object, k, None)
            if(value):
                value = value

            if k == 'lisence_confirm':
                value = self._confirm_lisence

            fields.update({k: value})

        return dict(fields)

    def wizard(self):

        data = {
            'msg': msg,
            'warning_text': None
        }

        for sys_req in self.requirements:
            cur_val = getattr(msg, 'current_' + sys_req)
            req_val = getattr(msg, 'suggested_' + sys_req)

            if cur_val < req_val:
                data['warning_text'] = getattr(msg,
                                               'insufficient_' + sys_req).format(cur_val, req_val)

                if sys_req == 'file_max':
                    self.exit_reason = data['warning_text']
                    time.sleep(3.5)
                    self.shutdown

                data['warning_text'] += '. Do you want to continue?'

        return template('wizard.tpl', data)


    def collect_data(self):
        for k, v in request.forms.items():
            if k == 'application_max_ram':
                v = int(v)

            if k == 'lisence_confirm':
                self._confirm_lisence = strtobool(v)
                continue

            setattr(self.install_object, k, v)

    def object_response(self, message=None, error=False,
                        field=None, redirect=False, redirect_url=None):
        response = {}
        response.update({'status': True})

        if error:
            response.update({
                'status': False,
                'errors': {
                    'field': field,
                    'message': message
                }
            })

        if redirect:
            response.update({'redirect_url': redirect_url})

        return dict(response)

    @middleware([body_req({'hostname', 'ip', 'lisence_confirm'})])
    def collect_system_info(self):
        errors = {}
        for k, v in request.forms.items():

            if v == 'localhost':
                errors.update({'hostname': msg.enter_hostname_local})

            if k == 'lisence_confirm':
                self._confirm_lisence = strtobool(v)
                continue

            setattr(self.install_object, k, str(v))

        return self.object_response()

    @middleware([validate_host({
        'orgName', 'admin_email', 'city', 'state', 'countryCode',
        'application_max_ram', 'oxtrust_admin_password'})])
    def collect_host(self):
        for k, v in request.forms.items():

            if k == 'application_max_ram':
                v = int(v)

            setattr(self.install_object, k, str(v))

        return dict({'status': True})

    def collect_services(self):
        params = request.forms
        for k, v in params.items():
            v = str(v) if k == 'oxd_url' else bool(strtobool(v))
            setattr(self.install_object, k, v)

        if params.installCasa:
            if not params.installOxd and not params.oxd_url:
                return dict({
                    'status': False,
                    'errors': [{
                        'field': 'oxd_url',
                        'message': 'Casa Required Oxd'
                    }]
                })

            if not params.installOxd:
                oxd_server_https = params.oxd_url
                oxd_connection_result = self.install_object.check_oxd_server(oxd_server_https)

                if oxd_connection_result is not True:
                    return dict({
                        'status': False,
                        'errors': [{
                            'field': 'oxd_url',
                            'message': msg.oxd_connection_error.format(oxd_server_https, oxd_connection_result)
                        }]
                    })

                oxd_hostname, oxd_port = self.install_object.parse_url(oxd_server_https)
                oxd_ssl_result = self.install_object.check_oxd_ssl_cert(oxd_hostname)

                if oxd_ssl_result:
                    return dict({
                        'status': False,
                        'errors': [{
                            'field': 'oxd_url',
                            'message': msg.oxd_ssl_cert_error.format(oxd_ssl_result['CN'], oxd_hostname)
                        }]
                    })

                self.install_object.oxd_server_https = oxd_server_https

        oxd_hostname, oxd_port = self.install_object.parse_url(self.install_object.oxd_server_https)

        if not oxd_port:
            oxd_port = 8445

        self.install_object.templateRenderingDict['oxd_hostname'] = oxd_hostname
        self.install_object.templateRenderingDict['oxd_port'] = str(oxd_port)

        return dict({'status': True})

    def collect_database(self):

        params = request.forms
        if params.wrends_install == '0':
            params.wrends_install = NONE

        if params.cb_install == '0':
            params.cb_install = NONE

        msg.backed_types = []
        self.install_object.wrends_install = params.wrends_install

        if self.install_object.wrends_install == LOCAL:
            self.install_object.ldap_hostname = 'localhost'
            self.install_object.ldapPass = params.wrends_password

        elif self.install_object.wrends_install == REMOTE:
            self.install_object.ldap_hostname = params.wrends_hosts
            self.install_object.ldapPass = params.wrends_password

            result = self.install_object.check_remote_ldap(
                        params.wrends_hosts,
                        self.install_object.ldap_binddn,
                        params.wrends_password)

            if not result['result']:
                return dict({
                    'status': False,
                    'errors': {
                        'field': 'wrends_hosts',
                        'message': result['reason']
                    }
                })

        self.install_object.cb_install = params.cb_install

        if self.install_object.cb_install == LOCAL:
            self.install_object.couchbase_hostname = 'localhost'
            self.install_object.cb_password = params.cb_password

        elif self.install_object.cb_install == REMOTE:
            self.install_object.couchbase_hostname = params.cb_hosts
            self.install_object.couchebaseClusterAdmin = params.cb_admin
            self.install_object.cb_password = params.cb_password

            result = self.install_object.test_cb_servers(params.cb_hosts)

            if not result['result']:
                return dict({
                    'status': False,
                    'errors': [{
                        'field': 'cb_hosts',
                        'message': result['reason']
                    }]
                })

        if self.install_object.cb_install is not NONE:
            self.install_object.cache_provider_type = 'NATIVE_PERSISTENCE'
            self.install_object.add_couchbase_post_messages()

        if self.install_object.wrends_install is not NONE and \
           not self.install_object.checkPassword(
               self.install_object.ldapPass):

            return dict({
                'status': False,
                'errors': [{
                    'field': 'wrends_password',
                    'message': msg.weak_password.format('Wrends')
                }]
            })

        if self.install_object.cb_install is not NONE and \
           not self.install_object.checkPassword(
               self.install_object.cb_password):

            return dict({
                'status': False,
                'errors': [{
                    'field': 'cb_password',
                    'message': msg.weak_password.format('Couchbase Server')
                }]
            })

        if self.install_object.wrends_install is not NONE or \
           self.install_object.cb_install is not NONE:

            if self.install_object.wrends_install is not NONE and \
               self.install_object.cb_install is not NONE:

                self.install_object.persistence_type = 'hybrid'

                return dict({
                    'status': True,
                    'redirect_url': '/storage_selection'
                })
            else:
                storage_list = list(
                    self.install_object.couchbaseBucketDict.keys())
                storage = 'ldap'

                if self.install_object.cb_install is not NONE:
                    storage = 'couchbase'

                for s in storage_list:
                    self.install_object.mappingLocations[s] = storage

                self.install_object.persistence_type = storage

                return dict({
                    'status': True,
                    'redirect_url': '/display_summary'
                })
        else:
            return dict({
                'status': False,
                'errors': [{
                    'field': 'wrends_install',
                    'message': msg.notify_select_backend
                }]
            })

        return dict({'status': True})

    def populate_dbbackend(self):
        fields = {}
        if self.install_object.wrends_install == LOCAL:
            if not self.install_object.ldapPass:
                fields['wrends_password'] = self.install_object.oxtrust_admin_password
            else:
                fields['wrends_password'] = self.install_object.ldapPass

        fields['wrends_hosts'] = self.install_object.ldap_hostname

        if self.install_object.cb_install == LOCAL:
            if not self.install_object.cb_password:
                fields['cb_password'] = self.install_object.oxtrust_admin_password

        fields['cb_hosts'] = self.install_object.couchbase_hostname
        fields['cb_admin'] = self.install_object.couchebaseClusterAdmin

        return dict(fields)

    def storage_selection(self):
        data = {
            'title': msg.StorageSelectionForm_label,
            'note': msg.unselected_storages
        }

        if request.method == 'POST':
            storage_list = list(self.install_object.couchbaseBucketDict.keys())

            for i, s in enumerate(storage_list):
                if i in [k for k, v in enumerate(request.forms)]:
                    self.install_object.mappingLocations[s] = 'ldap'
                else:
                    self.install_object.mappingLocations[s] = 'couchbase'

            return redirect('display_summary')

        choices = []
        for i, s in enumerate(self.install_object.couchbaseBucketDict.keys()):
            choice = {'key': i, 'label': s}
            if self.install_object.mappingLocations[s] == 'ldap':
                choice.update({'checked': 'checked'})

            choices.append(choice)
        data.update({'choices': choices})
        return template('storage_selection', data)

    def display_summary(self):
        data = {
            'title': msg.DisplaySummaryForm_label,
        }

        if self.install_object.wrends_install is not NONE \
           and self.install_object.cb_install is not NONE:
            data.update({'back_url': '/storage_selection'})
        else:
            data.update({'back_url': '/'})

        if request.method == 'POST':
            self.install_object.check_properties()
            return redirect('/installation')

        myfields_1 = ("hostname", "orgName", "os_type", "city", "state",
                      "countryCode", "application_max_ram")

        myfields_2 = ("installOxAuth", "installOxTrust", "installHttpd",
                      "installSaml", "installOxAuthRP", "installPassport",
                      "installGluuRadius", "installOxd", "installCasa",
                      "java_type", "backend_types", "wrends_storages")
        specs = {}
        for field in myfields_1:
            label = getattr(msg, field + '_label')
            value = getattr(self.install_object, field)
            specs[label] = value

        data['specs'] = specs

        packages = {}
        for field in myfields_2:
            label = getattr(msg, field+'_label')
            if field == 'backend_types':
                bt_ = []
                if self.install_object.wrends_install == LOCAL:
                    bt_.append('wrends')
                elif self.install_object.wrends_install == REMOTE:
                    bt_.append('wrends[R]')

                if self.install_object.cb_install == LOCAL:
                    bt_.append('couchbase')
                elif self.install_object.cb_install == REMOTE:
                    bt_.append('couchbase[R]')
                value = ', '.join(bt_)
            elif field == 'wrends_storages':
                if self.install_object.wrends_install is not NONE \
                   and self.install_object.cb_install is not NONE:
                    wds_ = []
                    for k in self.install_object.mappingLocations:
                        if self.install_object.mappingLocations[k] == 'ldap':
                            wds_.append(k)
                    value = ', '.join(wds_)
            else:
                value = getattr(self.install_object, field)

            packages[label] = value

        data['packages'] = packages
        return template('display_summary', data)

    def install_handler(self):
        data = {
            'title': msg.InstallStepsForm_label,
            'installing': msg.installing_label,
            'description': "",
            'progress_max_value': msg.installation_step_number + 1
        }

        t = threading.Thread(target=self.install_object.do_installation, args=(self.queue,))
        t.daemon = True
        t.start()
        return template('installation', data)

    def installation(self):
        data = {}
        if not self.queue.empty():
            qdata = self.queue.get()

            if qdata[0] == COMPLETED:
                if self.install_object.post_messages:
                    data['message'] = '\n'.join(self.install_object.post_messages)
                data['progress_percentage'] = qdata[0]
                data['message'] = msg.installation_completed.format(self.install_object.hostname)
                data['installing'] = qdata[2]
                response.content_type = 'application/json'
                return json.dumps(data)

            elif qdata[0] == ERROR:
                data['progress_percentage'] = qdata[0]
                data['installing'] = qdata[2]
                data['message'] = msg.installation_error + "\n" + qdata[2]
                response.content_type = 'application/json'
                return json.dumps(data)

            data['progress_percentage'] = qdata[0]
            data['installing'] = qdata[2]

            if not data.get('description') or data['description'] != qdata[1]:
                if hasattr(msg, 'installation_description_' + qdata[1]):
                    desc = getattr(msg, 'installation_description_' + qdata[1])
                else:
                    desc = msg.installation_description_gluu

                data['description'] = '\n'.join(textwrap.wrap(text=desc))

            response.content_type = 'application/json'
            return json.dumps(data)

    def post_install_handler(self):
        data = {
            'title': 'Post Installation'
        }

        services = {
            'installSaml': '/opt/shibboleth-idp',
            'installPassport': '/opt/gluu/node/passport',
            'installOxd': '/opt/oxd-server',
            'installCasa': '/opt/gluu/jetty/casa',
            'installGluuRadius': '/opt/gluu/radius/super-gluu-radius-server.jar'
        }

        components = []
        for service, path in services.items():
            components.append({
                'service': service,
                'installed': True if os.path.exists(path) else False,
                'label': getattr(msg, 'ask_' + service)
            })

        data.update({'components': components})
        return template('post_installation', data)

    def add_services_handler(self):

        service_to_install = []

        for k, v in request.json.items():
            service_to_install.append(k)

        t = threading.Thread(target=self.add_service_task, args=(self.queue, service_to_install))
        t.daemon = True
        t.start()

        return dict({'status': True, 'service_to_install': service_to_install})

    def add_service_task(self, q, service_to_install):

        args_for_installer = {
            'installSaml': ('addshib', 'SAML Shibboleth IDP'),
            'installPassport': ('addpassport', 'Passport'),
            'installOxd': ('addoxd', 'Oxd Server'),
            'installCasa': ('addcasa', 'Gluu Casa'),
            'installGluuRadius': ('addradius', 'Gluu Radius Server'),
        }

        for service in service_to_install:
            os.system('cd /install/community-edition-setup; python3 post-setup-add-components.py -' + args_for_installer[service][0])
            q.put((service, ' Installing {}'.format(service)))
            time.sleep(20)
        q.put((COMPLETED, 'done'))

    def get_log(self):
        data = {}

        if not self.queue.empty():
            qdata = self.queue.get()

            data['progress_percentage'] = 10
            data['message'] = qdata[1]
            data['service'] = qdata[0]

            if qdata[0] == COMPLETED:
                data['progress_percentage'] = COMPLETED
                data['message'] = 'Installation Completed'

            elif qdata[0] == ERROR:
                data['progress_percentage'] = ERROR
                data['message'] = 'Opps something went wrong'

        response.content_type = 'application/json'
        return json.dumps(data)

    def shutdown(self):
        self._app.close()
