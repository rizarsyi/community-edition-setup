% rebase('layout.tpl, title={{title}}
  <div class="row">
    <div class="col">
      <div class="card mb-3">
        <div class="card-header">
          <h1>{{ title }}</h1>
        </div>
        <div class="card-body">
          <p>{{description}}</p>

          <ul>
            % for key, value in details.items()
              <li>{{key}} {{value}}</li>
            % end
          </ul>

          <form method="POST" action="/">
            <div class="form-group form-check">
              {{ form.confirm_lisence }}
              {{ form.confirm_lisence.label }}
            </div>
            <div class="float-right">
              <button type="submit" class="btn btn-primary">Next</button> 
              <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#exampleModal">Quit</button>
            </div>
          </form>
        </div>
      </div>
      <div class="alert alert-info fade show" role="alert">
        <strong>{{ info }} </strong>
      </div>
    </div>
  </div> 
  % include('quit_notif.html)
  % include(warning_box.tpl)
  <script>
    $(document).ready(function(){
      $('#lisenceConfirm').on('change', function(){
        if($(this).is(':checked')){
          $(this).attr('value', true);
        }else{
          $(this).attr('value', false);
        }
      });

      {% if warning_text %}
        $('#warningModal').modal('toggle')
      {% endif %}
    });
  </script>
