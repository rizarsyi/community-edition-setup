% rebase('layout.tpl', title=title)

<div class="card">
  <div class="card-header">
    <h1>{{ title }}</h1>
  </div>
  <div class="card-body">
    <form method="POST" action="/storage_selection">
        % for choice in choices:
          <div class="custom-control custom-switch">
            <input {{ choice['checked'] }}  id="wrends_storage-{{choice['key']}}" class="custom-control-input" name="{{choice['label']}}" type="checkbox" value="{{choice['key']}}">
            <label class="custom-control-label" for="wrends_storage-{{choice['key']}}">{{ choice['label'] }}</label>
          </div>
        % end
      <p>{{ note }}</p>
      <button type="submit" class="btn btn-primary">Next</button>
      <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#exampleModal">Quit</button>
    </form>
  </div>
</div>
% include('quit_notif.tpl')

