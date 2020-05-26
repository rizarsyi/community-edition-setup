<!DOCTYPE html>
<html lang=en>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="shortcut icon" href="https://gluu.org/docs/gluu-server/favicon.ico">
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">

  <title>Gluu Server | Community Edition Setup</title>
  <style>
    .stepwizard-step p {
        margin-top: 10px;
    }

    .stepwizard-row {
        display: table-row;
    }

    .stepwizard {
        display: table;
        width: 100%;
        position: relative;
    }

    .stepwizard-step button[disabled] {
        opacity: 1 !important;
        filter: alpha(opacity=100) !important;
    }

    .stepwizard-row:before {
        top: 14px;
        bottom: 0;
        position: absolute;
        content: " ";
        width: 100%;
        height: 1px;
        background-color: #ccc;
        z-order: 0;

    }

    .stepwizard-step {
        display: table-cell;
        text-align: center;
        position: relative;
    }

    .btn-circle {
      width: 30px;
      height: 30px;
      text-align: center;
      padding: 6px 0;
      font-size: 12px;
      line-height: 1.428571429;
      border-radius: 15px;
    }
  </style>
</head>
<body>
  <nav class="navbar navbar-dark bg-dark mb-3">
    <a href="#" title="Gluu Server 4.1 Docs" class="navbar-brand">
      <img src="https://gluu.org/docs/gluu-server/gluu.jpg" width="30" height="30" class="d-inline-block align-top">
         Gluu Community Edition
   </a>
  </nav>

  <div class="container">
    <div class="stepwizard">
        <div class="stepwizard-row setup-panel">
            <div class="stepwizard-step">
                <a href="#systemInfo" type="button" class="btn btn-primary btn-circle">1</a>
                <p>{{ msg.MAIN_label }}</p>
            </div>
            <div class="stepwizard-step">
              <a href="#setupHost" class="btn btn-default btn-circle disabled" tabindex="-1" role="button" aria-disabled="true">2</a>
              <p>{{ msg.HostForm_label }}</p>

            </div>
            <div class="stepwizard-step">
                <a href="#setupService" type="button" class="btn btn-default btn-circle disabled" aria-disabled="true">3</a>
                <p>{{ msg.ServicesForm_label}}</p>
            </div>
          <div class="stepwizard-step">
                <a href="#setupDatabase" type="button" class="btn btn-default btn-circle disabled" aria-disabled="true">3</a>
                <p>{{ msg.DBBackendForm_label}}</p>
            </div>
        </div>
    </div>
    <div class="row">
      <div class="col-md-12">

        <form id="setupForm" role="form" class="needs-validation">
          <div class="row setup-content" id="systemInfo">
            <div class="col-md-12">
              % include('system_information.tpl')
            </div>
          </div>
          <div class="row setup-content" id="setupHost">
            <div class="col-md-12">
              % include('setup_host.tpl')
            </div>
          </div>
          <div class="row setup-content" id="setupService">
            <div class="col-md-12">
              % include('setup_service.tpl')
            </div>
          </div>
          <div class="row setup-content" id="setupDatabase">
            <div class="col-md-12">
              % include('setup_database.tpl')
            </div>
          </div>
        </form>
      </div>
    </div>
    % include('quit_notif.tpl')
    % include('warning_box.tpl')
  </div>
  <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha384-vk5WoKIaW/vJyUAd9n/wmopsmNhiy+L2Z+SBxGYnUkunIxVxAv/UtMOhba/xskxh" crossorigin="anonymous"></script>
  <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
  <script>
    $(document).ready(function () {
      % if warning_text:
        $('#warningModal').modal('toggle')
      % end

      var navListItems = $('div.setup-panel div a'),
        allWells = $('.setup-content'),
        allNextBtn = $('.nextBtn'),
        allBackBtn = $('.backBtn'),
        urls = { 
          'systemInfo': '/collect-system-info',
          'setupHost': '/collect-host',
          'setupService': '/collect-services',
          'setupDatabase': '/collect-database'
        };

      initialize = function(){
         $.get('/initialize', function(data, status){
          
          if(data.installed){
            window.location.href = '/post-installation'
          }

          $.each(data, function(i, item){
            let $el = $('input[name="'+i+'"]')
            
            if($el.attr('type') == 'checkbox' && item==true){
              $el.prop('checked', item)

              if($el.attr('name') == 'installCasa'){
                $el.trigger('change')
              }
            }

            if($el.attr('type') == 'radio'){
              $('input[name="'+i+'"][value="'+ item + '"]').prop('checked', true).trigger('change')
            }else{
              $el.val(item);
            }
          });
        });
      }

      populateDatabase = function(){
        $.get('/populate-dbbackend', function(data, status){
          $.each(data, function(i, item){
            let $el = $('input[name="'+i+'"]')
            $el.val(item);
          });
        })
        
      }

      showWrendsOptions = function(value){
        if(value == 0){
          $('#wrendsPassword').collapse('hide');
          $('#wrendsHost').collapse('hide');
        }else if(value == 1){
          $('#wrendsPassword').collapse('show');
          $('#wrendsHost').collapse('hide');
        }else if(value == 2){
          $('#wrendsPassword').collapse('show');
          $('#wrendsHost').collapse('show');
        }
      }

      showCbOptions = function(value){
        if(value == 1){
          $('#cbAdmin').collapse('show');
          $('#cbPassword').collapse('show');
          $('#cbHost').collapse('hide');
        }else if(value == 2){
          $('#cbPassword').collapse('show');
          $('#cbHost').collapse('show');
          $('#cbAdmin').collapse('show');
        }else if(value == 0){
          $('#cbPassword').collapse('hide');
          $('#cbHost').collapse('hide');
          $('#cbAdmin').collapse('hide');
        }
      }

      validateFields = function(url, params){
        return Promise.resolve($.post(url, params));
      }

      showOxdUrl = function(){
        if($('#installCasa').is(':checked')){
          $('#OxdUrl').collapse('show');
        }else{
          $('#OxdUrl').collapse('hide');
        }
      };

      initialize();
      allWells.hide();

      navListItems.click(function (e) {
          e.preventDefault();
          var $target = $($(this).attr('href')),
                  $item = $(this);

          if (!$item.hasClass('disabled')) {
              $('#setupForm').removeClass("was-validated")
              navListItems.removeClass('btn-primary').addClass('btn-default');
              $item.addClass('btn-primary');
              allWells.hide();
              $target.show();
              $target.find('input:eq(0)').focus();

              if($target.attr('id') == 'setupDatabase'){
                populateDatabase() 
              }
          }
      });
      
      allBackBtn.on('click', function(){
        var curStep = $(this).closest(".setup-content"),
            curStepBtn = curStep.attr("id"),
            backStepWizard = $('div.setup-panel div a[href="#' + curStepBtn + '"]').parent().prev().children("a");

        backStepWizard.trigger('click');
      });

      allNextBtn.click(function(){
          var curStep = $(this).closest(".setup-content"),
              curStepBtn = curStep.attr("id"),
              nextStepWizard = $('div.setup-panel div a[href="#' + curStepBtn + '"]').parent().next().children("a"),
              curInputs = curStep.find("input[type='text'], input[type='url'], input[type='checkbox'], input[type='email'], input[type='password'], input[type='radio']"),
              isValid = true;

          $(".form-group").removeClass("has-error");
          params = curInputs.serialize()
          
          var test = validateFields(urls[curStepBtn], params)
           
          $('#setupForm').addClass('was-validated')

          for(var i=0; i<curInputs.length; i++){
            curInputs[i].setCustomValidity('');
          }

          test.then(function(data){
            if(data.status && isValid){
              nextStepWizard.removeClass("disabled").trigger("click");
              if(data.redirect_url){
                window.location.href = data.redirect_url
              }
              return 
            }

            $.each(data.errors, function(i, item){
              el = $("input[name='" + item.field + "']")[0]
              el.setCustomValidity(item.message)
              feedback = $(el).closest('div').find('.invalid-feedback')[0]
              $(feedback).html("<p>" + item.message + "</p>")
            });

            $('#setupForm').addClass('was-validated')
          });
      });

      $('div.setup-panel div a.btn-primary').trigger('click');

      $('input[name="wrends_install"]').on('change', function(){
        showWrendsOptions($(this).val());
      });

      $('input[name="cb_install"]').on('change', function(){
        showCbOptions($(this).val())
      });

      $('#installCasa').on('change', function(){
        if($(this).is(':checked')){
          $('#OxdUrl').collapse('show');
          $("input[name='oxd_url']").attr("required", "required")
        }else{
          $('#OxdUrl').collapse('hide');
        }
      });

      $('#lisenceConfirm').on('change', function(){
        if($(this).is(':checked')){
          $(this).attr('value', true);
        }else{
          $(this).attr('value', false);
        }
      });

      $('#setupForm').submit(function(event){
        event.preventDefault()
      });

      $('.service-component').on('change', function(){
        if($(this).is(':checked')){
          $(this).attr('value', true);
        }else{
          $(this).attr('value', false);
        }
      });
    });
  </script>
</body>
</html>

