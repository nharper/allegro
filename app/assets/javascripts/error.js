window.addEventListener('load', function() {
  var details_link = document.querySelector('.error a');
  var error_detail = document.querySelector('.error .detail');

  if (details_link) {
    details_link.addEventListener('click', function() {
      if (details_link.innerText == 'Hide details') {
        error_detail.classList.add('hidden');
        details_link.innerText = 'Show details';
      } else {
        error_detail.classList.remove('hidden');
        details_link.innerText = 'Hide details';
      }
    });
  }
});
