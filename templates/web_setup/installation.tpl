% rebase('layout.tpl', title=title)
<div id="alert" class="alert mt-3 collapse" role="alert">
  <h4 id="alertHeading" class="alert-heading">Well done!</h4>
  <p id="alertMessage"></p>
</div>
<div class="card">
  <div class="card-header">
    <h1>{{ title }}</h1>
  </div>
  <div class="card-body">
    <div class="progress">
      <div id="progress" class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" aria-valuemin="0" aria-valuemax="{{ progress_max_value }}"></div>
    </div>

    <p id="installation"></p>
    <p id="description"></p>

    <div id="nextAction" class="collapse">
      <a href="/quit" class="btn btn-success">Finish</a>
      <a href="/post-installation" class="btn btn-primary">Install more components</a>
    </div>
  </div>
</div>

<script>
  const progressBar = document.getElementById('progress');
  const installationMsg = document.getElementById('installation');
  const description = document.getElementById('description');
  const alertBox = document.getElementById('alert');
  const alertHeading = document.getElementById('alertHeading');
  const alertMessage = document.getElementById('alertMessage');
  const nextAction = document.getElementById('nextAction');

  const sendHttpRequest = (method, url) => {
    const promise = new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open(method, url);

      xhr.responseType = 'json';

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

      xhr.send(null);
    });
    return promise;
  };

  const getData = () => {

    sendHttpRequest('GET', '/install').then(responseData =>{
      let progress = 100 / progressBar.getAttribute('aria-valuemax'),
          percentage = 0;

      if(responseData.progress_percentage == -99){

        progressBar.setAttribute('value', 100)
        progressBar.style.width = 100 + '%'
        installationMsg.innerHTML = ""
        description.innerHTML = ""

        alertBox.classList.add('show');
        alertBox.classList.add('alert-success');
        alertHeading.innerHTML = responseData.installing;
        alertMessage.innerHTML = responseData.message;
        clearInterval(myTimer)
        nextAction.classList.add('show')
        return
      }

      if(responseData.progress_percentage == -101){
        progress = 0;
        clearInterval(myTimer)
        alertBox.classList.add('show');
        alertBox.classList.add('alert-danger');
        alertHeading.innerHTML = "Error";
        alertMessage.innerHTML = responseData.message;
        return
      }

      progress = responseData.progress_percentage * progress;
      progressBar.setAttribute('value', progress)
      progressBar.style.width = progress + '%'
      installationMsg.innerHTML = responseData.installing
      description.innerHTML = responseData.description
    });
  };

  var myTimer = setInterval(getData, 1000);
</script>

