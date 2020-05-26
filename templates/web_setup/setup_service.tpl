<div class="card w-100">
  <div class=card-header>
    {{ msg.ServicesForm_label }}
  </div>
  <div class="card-body">
    <div class="form-group row">
      <label class="col-sm-3 col-form-label">{{ msg.ask_installHttpd }}</label>
      <div class="col-sm-5">
        <div class="form-check">
          <input type="checkbox" name="installHttpd" class="form-control form-check-input service-component">
        </div>
      </div>
    </div>

    <div class="form-group row">
      <label class="col-sm-3 col-form-label">{{ msg.ask_installSaml }}</label>
      <div class="col-sm-5">
        <div class="form-check">
          <input type="checkbox" name="installSaml" class="form-control form-check-input service-component">
        </div>
      </div>
    </div>

    <div class="form-group row">
      <label class="col-sm-3 col-form-label">{{ msg.ask_installOxAuthRP }}</label>
      <div class="col-sm-5">
        <div class="form-check">
          <input type="checkbox" name="installOxAuthRP" class="form-control form-check-input service-component">
        </div>
      </div>
    </div>

    <div class="form-group row">
      <label class="col-sm-3 col-form-label">{{ msg.ask_installPassport }}</label>
      <div class="col-sm-5">
        <div class="form-check">
          <input type="checkbox" name="installPassport" class="form-control form-check-input service-component">
        </div>
      </div>
    </div>

    <div class="form-group row">
      <label class="col-sm-3 col-form-label">{{ msg.ask_installGluuRadius }}</label>
      <div class="col-sm-5">
        <div class="form-check">
          <input type="checkbox" name="installGluuRadius" class="form-control form-check-input service-component">
        </div>
      </div>
    </div>

    <div class="form-group row">
      <label class="col-sm-3 col-form-label">{{ msg.ask_installOxd }}</label>
      <div class="col-sm-5">
        <div class="form-check">
          <input type="checkbox" name="installOxd" class="form-control form-check-input service-component">
        </div>
      </div>
    </div>

    <div class="form-group row">
      <label class="col-sm-3 col-form-label">{{ msg.ask_installCasa }}</label>
      <div class="col-sm-5">
        <div class="form-check">
          <input id="installCasa" type="checkbox" name="installCasa" class="form-control form-check-input service-component">
        </div>
      </div>
    </div>

    <div id="OxdUrl" class="form-group row collapse hide">
      <label class="col-sm-3 col-form-label">{{ msg.oxd_url_label }}</label>
      <div class="col-sm-5">
        <div class="form-check">
          <input type="text" name="oxd_url" class="form-control">
          <div class="invalid-feedback">Oxd Url Required</div>
        </div>
      </div>
    </div>
    <div class="float-right">
      <a href="#" class="btn backBtn btn-primary">Back</a>
      <button id="firstStep" class="btn btn-primary nextBtn btn pull-right" type="button" >Next</button>
      <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#exampleModal">Quit</button>
    </div>
  </div>
</div>
