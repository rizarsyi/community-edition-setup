<div class="card w-100 mb-3">
  <h5 class="card-header">{{ msg.MAIN_label }}</h5>
  <div class="card-body">
    <p class="card-title">{{ msg.decription }}</p>

    <ul class="card-text">
      <li> {{ msg.os_type_label }} {{ msg.os_type }}</li>
      <li> {{ msg.init_type_label }} {{ msg.os_initdaemon }}</li>
      <li> {{ msg.httpd_type_label }} {{ msg.apache_version }}</li>
    </ul>

    <input type="hidden" name="step" value="system_info">

    <div class="form-group row">
      <label class_="col-sm-2 col-form-label">IP Address</label>
      <div class="col-sm-5">
        <input type="text" class="form-control" name="ip" readonly>
      </div>
    </div>

    <div class="form-group row">
      <label class_="col-sm-2 col-form-label">Hostname</label>
      <div class="col-sm-5">
        <input type="text" name="hostname" required class="form-control">

          <div class="invalid-feedback">
            {{ msg.enter_hostname_local }}
          </div>
          <div class="valid-feedback">
          </div>
      </div>
    </div>

    <div class="form-group form-check">
      <input type="checkbox" name="lisence_confirm" required class="form-check-input" id="lisenceConfirm">
      <label class="form-check-label" for="exampleCheck1">{{ msg.acknowledge_lisence }}</label>
      <div class="invalid-feedback">
        You must agree before submitting.
      </div>
    </div>

    <div class="float-right">
      <button id="firstStep" class="btn btn-primary nextBtn btn pull-right" type="button" >Next</button>
      <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#exampleModal">Quit</button>
    </div>
  </div>
</div>
<div class="alert alert-info fade show" role="alert">
  <strong>{{ msg.setup_properties_warning }} </strong>
</div>
