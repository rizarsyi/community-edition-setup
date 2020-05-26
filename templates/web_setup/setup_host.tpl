<div class="card w-100 mb-3">
  <h5 class="card-header">
    {{ msg.HostForm_label }}
  </h5>

  <div class="card-body">
      <h5>{{ msg.cert_info_label }}</h5>
      <hr class="mb-4"></hr>

      <div class="form-group row">
        <label class_="col-sm-2 col-form-label">{{ msg.orgName_label }}</label>
      
        <div class="col-sm-5">
          <input type="text" class="form-control" name="orgName" required>
          <div class="invalid-feedback"></div>
        </div>
      </div>

      <div class="form-group row">
        <label class_="col-sm-2 col-form-label">{{ msg.admin_email_label }}</label>
        <div class="col-sm-5">
          <input type="email" class="form-control" name="admin_email" required>
          <div class="invalid-feedback"></div>
        </div>
      </div>

      <div class="form-group row">
        <label class_="col-sm-2 col-form-label">{{ msg.city_label }}</label>
        <div class="col-sm-5">
          <input type="text" class="form-control" name="city" required>
          <div class="invalid-feedback"></div>
        </div>
      </div>

      <div class="form-group row">
        <label class_="col-sm-2 col-form-label">{{ msg.state_label }}</label>
        <div class="col-sm-5">
          <input type="text" class="form-control" name="state" required>
          <div class="invalid-feedback"></div>
        </div>
      </div>

      <div class="form-group row">
        <label class_="col-sm-2 col-form-label">{{ msg.countryCode_label }}</label>
        <div class="col-sm-5">
          <input type="text" class="form-control" maxlength="2" minlength="2" name="countryCode" required>
          <div class="invalid-feedback"></div>
        </div>
      </div>

      <hr class="mb-4"></hr>
      <h5>{{ msg.sys_info_label }}</h5>
      <hr class="mb-4"></hr>
      <div class="form-group row">
        <label class_="col-sm-2 col-form-label">{{ msg.application_max_ram_label }}</label>
        <div class="col-sm-5">
          <input type="text" class="form-control" name="application_max_ram" readonly>
        </div>
      </div>

      <div class="form-group row">
        <label class_="col-sm-2 col-form-label">{{ msg.oxtrust_admin_password_label }}</label>
        <div class="col-sm-5">
          <input type="password" class="form-control" minlength="6" name="oxtrust_admin_password" required>
          <div class="invalid-feedback"></div>
        </div>
      </div>
      <div class="float-right">
        <a href="#" class="btn backBtn btn-primary">Back</a>

        <button class="btn btn-primary nextBtn btn pull-right" type="button" >Next</button>
        <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#exampleModal">Quit</button>
      </div>
  </div>
</div>
