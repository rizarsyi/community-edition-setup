% rebase('layout.tpl', title=title)
  <div class="card">
    <div class="card-header">
      <h1>{{ title }}</h1>
    </div>
    <div class="card-body">
      <table class="mb-3" style="width: 100%">
        <tbody>
          % for key, value in specs.items():
            <tr>
              <td width="40%">{{key}}</td>
              <td width="60%">{{value}}</td>
            </tr>
          % end
        </tbody>
      </table>

      <table class="mt-3" style="width: 100%">
        <tbody>
          % for key, value in packages.items():
            <tr>
              <td width="40%">
                {{key}}
              </td>
              <td width="60%">

                % if value == True:
                  <span class="badge badge-success">{{value}}</span>
                % elif value == False:
                  <span class="badge badge-danger">{{value}}</span>
                % else:
                  {{value}}
                % end

              </td>

            </tr>
          % end
        </tbody>
      </table>
      <form method="POST" action="/display_summary">
        <div class="float-right">
          <a href="{{ back_url }}" class="btn btn-primary">Back</a>
          <button type="submit" class="btn btn-primary">Next</button>
          <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#exampleModal">Quit</button>
        </div>
      </form>
    </div>
  </div>
  % include('quit_notif.tpl')
