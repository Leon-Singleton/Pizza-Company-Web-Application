function menuFunction() {
  document.getElementById("menu-dropdown").classList.toggle("showmenu");
}

window.onclick = function(event) {
  if (!event.target.matches('.menubtn')) {
    var dropdownRows = document.getElementsByClassName("menu-content");
    var i;
    for (i = 0; i < dropdownRows.length; i++) {
      var dropdownMenu = dropdownRows[i];
      if (dropdownMenu.classList.contains('showmenu')) {
        dropdownMenu.classList.remove('showmenu');
      }
    }
  }
}
