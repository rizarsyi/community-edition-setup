<div class="card w-100">
  <h5 class="card-header">
    {{ msg.DBBackendForm_label }}
  </h5>
  <div class="card-body">
    <fieldset class="form-group">
      <div class="row">
        <legend class="col-form-label col-sm-2 pt-0">{{ msg.ask_wrends_install }}</legend>
        <div class="col-sm-10">
          % for k, v in enumerate(msg.wrends_install_options, start=0):
            <div class="form-check">
              <input class="form-check-input" type="radio" name="wrends_install" id="gridRadios1" value="{{ k }}">
              <label class="form-check-label" for="gridRadios1">
                {{ v }}
              </label>
            </div>
          % end
        </div>
      </div>
    </fieldset>

    <div id="wrendsPassword" class="form-group row collapse hide">
      <label class="col-sm-2 col-form-label">{{ msg.password_label }}</label>
      <div class="col-sm-3">
        <input type="password" name="wrends_password" class="form-control">
        <div class="invalid-feedback"></div>
      </div>
    </div>

    <div id="wrendsHost" class="form-group row collapse hide">
      <label class="col-sm-2 col-form-label">{{ msg.hosts_label }}</label>
      <div class="col-sm-3">
        <input type="text" name="wrends_hosts" class="form-control">
        <div class="invalid-feedback"></div>
      </div>
    </div>

    <fieldset class="form-group">
      <div class="row">
        <legend class="col-form-label col-sm-2 pt-0">{{ msg.ask_cb_install }}</legend>
        <div class="col-sm-10">
          % for k, v in enumerate(msg.cb_install_options, start=0):
            <div class="form-check">
              <input class="form-check-input" type="radio" name="cb_install" id="gridRadios1" value={{ k }}>
              <label class="form-check-label" for="gridRadios1">
                {{ v }}
              </label>
            </div>
          % end
        </div>
      </div>
    </fieldset>

    <div id="cbAdmin" class="form-group row collapse hide">
      <label class="col-sm-2 col-form-label">{{ msg.username_label }}</label>
      <div class="col-sm-3">
        <input type="text" name="cb_admin" class="form-control">
        <div class="invalid-feedback"></div>
      </div>
    </div>

    <div id="cbPassword" class="form-group row collapse hide">
      <label class="col-sm-2 col-form-label">{{ msg.password_label }}</label>
      <div class="col-sm-3">
        <input type="password" name="cb_password" class="form-control">
        <div class="invalid-feedback"></div>
      </div>
    </div>

    <div id="cbHost" class="form-group row collapse hide">
      <label class="col-sm-2 col-form-label">{{ msg.hosts_label }}</label>
      <div class="col-sm-3">
        <input type="text" name="cb_hosts" class="form-control">
        <div class="invalid-feedback"></div>
      </div>
    </div>
    <div class="float-right">
      <a href="#" class="btn backBtn btn-primary">Back</a>
      <button id="firstStep" class="btn btn-primary nextBtn btn pull-right" type="button" >Next</button>
      <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#exampleModal">Quit</button>
    </div>
  </div>
</div>
