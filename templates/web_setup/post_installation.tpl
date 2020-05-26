% rebase('layout.tpl', title=title)
  <div class="col-md-12">
    <div class="card">
      <div class=card-header>
        {{ title }}
      </div>
      <div class="card-body">

        <form id="installServices" action="/add-services" method="POST" novalidate>
          % for component in components:
            % installed = 'checked' if component['installed'] else ''
            <div class="form-group row">
              <div class="mr-5">
                <div class="custom-control custom-switch">
                  <input id="{{ component['service'] }}" name="{{ component['service'] }}" type="checkbox" class="custom-control-input check-service" {{ installed }} value="{{ component['installed'] }}"> 
                  <label class="custom-control-label" for="{{ component['service'] }}">{{ component['label'] }}</label>
                </div>
              </div>

              <div id="{{component['service']}}-loader" class="align-items-center collapse">
                <span class="spinner-border spinner-border-sm ml-auto text-info" role="status" aria-hidden="true"></span>
                <span class="ml-3 text-info">Loading...</span>
              </div>
            </div>

            % if component['service'] == 'installCasa':
              <div id="OxdUrl" class="form-group row collapse hide">
                <label class="col-sm-3 col-form-label">Oxd Server Url</label>
                <div class="col-sm-5">
                  <div class="form-check">
                    <input type="text" name="oxd_url" disabled class="form-control" required>
                    <div class="invalid-feedback"></div>
                  </div>
                </div>
              </div>
            %end
          % end

          <div class="float-right">
            <button type="submit" class="btn btn-primary">Install</button>
            <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#exampleModal">Quit</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
% include('quit_notif.tpl')

  <script charset="utf-8">
    $(document).ready(function(){

      showOxdUrl();

      function showOxdUrl(){
        if($('#installCasa').is(':checked')){
          $('#OxdUrl').collapse('show');
          $('input[name="oxd_url"]').prop('disabled', false)

        }else{
          $('#OxdUrl').collapse('hide');
          $('input[name="oxd_url"]').prop('disabled', true)
        }
      };

      $('#installCasa').on('change', function(){
        showOxdUrl()
      });
      
      $('.check-service').on('change', function(){
        if($(this).is(":checked")){
          $(this).val(true)
        }else{
          $(this).val(false)
        }
      });

    });

    const progressBar = document.getElementById('progress');
    const form = document.getElementById('installServices');
    const actionButton = document.querySelector('button');
    var currentService = '';

    const sendHttpRequest = (method, url, data) => {
      const promise = new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        var object = {};
        xhr.open(method, url);

        xhr.responseType = 'json';

        if(data){
          xhr.setRequestHeader('Content-Type', 'application/json');
          data.forEach((value, key) => {object[key] = value});
        }

        xhr.onload = () => {
          if(xhr.status >= 400) {
            reject(xhr.response);
          } else {
            resolve(xhr.response);
          }
        };

        xhr.onerror = () => {
          reject('Something went wrong!');
        }

        xhr.send(JSON.stringify(object));
      });
      return promise;
    };

    const getData = () => {

      sendHttpRequest('GET', '/get-log').then(responseData =>{


        if(responseData.progress_percentage == -99){
          console.log('done')
          var loader = document.getElementById(currentService + '-loader')
          loader.innerHTML = '<span class="badge badge-pill badge-success">Success</span>';
          clearInterval(myTimer)
          actionButton.disabled = false
          return 
        }

        if(responseData.hasOwnProperty('service')){

          if(currentService.length == 0){
            currentService = responseData.service
          } 
          if(currentService !== responseData.service){
            var loader = document.getElementById(currentService + '-loader')
            loader.innerHTML = '<span class="badge badge-pill badge-success">Installation complete</span>';
          }

          currentService = responseData.service
          var loader = document.getElementById(currentService + '-loader')
          loader.classList.add('show')
        }
      });
    };

    const sendData = () => {

      const FD = new FormData(form)
      sendHttpRequest('POST', '/add-services', FD).then(responseData => {
        if(responseData.status){
          actionButton.disabled = true
          myTimer = setInterval(getData, 1000);
        }
      })
      .catch(err => {
        console.log(err);
      });
    }

    var myTimer = ""
    form.addEventListener("submit", function(e){
      e.preventDefault();
      sendData();
    });
  </script>

