//=================================================
//*creating content tabs for mobile layout

function openPage(pageName, element, color) {
//? onclick = "openPage('forecast', this, 'green')

  // declares variables;
  var i, tabContent, tabLinks;

  // loops through all <div> elements with .tab-content class, hides them as default
  tabContent = document.getElementsByClassName("tab-content");
  for (i = 0; i < tabContent.length; i++) {
    tabContent[i].style.display = "none";
  }

  // loops through all <button> elements with .tab-link class, empties background color.
  tabLinks = document.getElementsByClassName("tab-link");
  for (i = 0; i < tabLinks.length; i++) {
    tabLinks[i].style.backgroundColor = "";
  }

  // takes page and displays as block element, adds color to the tab button
  document.getElementById(pageName).style.display = "block";
  element.style.backgroundColor = color;
}

// Get the element with id="defaultOpen" and click on it
if (window.innerWidth <= 750) {
  document.getElementById("defaultOpen").click();
}

//=================================================
// previous searches

// search button event listener

$("#search-button").on("click", function() {
  let searchValue = $("#search-bar").val().trim();
  const previousSearches = JSON.parse(localStorage.getItem("astro-searches")) || [];
  console.log(previousSearches);
  if (!(previousSearches.indexOf(searchValue) > -1)) {
      previousSearches.push(searchValue);
      localStorage.setItem("astro-searches", JSON.stringify(previousSearches));
    }
  })

let isDropdownVis = false;
// we use this to declare if the dropdown is visible or not, naturally false

$("#search-bar").on("click", function (e) {
  // console.log("clicked");
  e.stopPropagation();
  // stopPropagation() method prevents further propagation of the event from bubbling out
  const previousSearches = JSON.parse(localStorage.getItem("astro-searches")) || [];
  // previousSearches does the same here as in the button function. Will err out if OR is not included
  if (previousSearches.length > 0){
    // checks if the localStorage array length is greater than 0 (not an empty array)
    $(".previousSearches").attr("id", "previousSearches");
    $("#previousSearches").empty();
    // adds id to the empty div in the html, to give it css properties and apply the rest of the javascript changes.
    isDropdownVis = true;
    for (i=0; i<previousSearches.length; i++) {
      $("#previousSearches").append($("<p></p>").text(previousSearches[i]).addClass("searchItem").on("click", function(e) {
        e.stopPropagation();
        $("#search-bar").val($(this).text());
        $("#previousSearches").empty();
        $(".previousSearches").attr("id", "");
        isDropdownVis = false;
      }));
    }
  } else {
    return;
  }
})

$("body").on("click", function (e) {
  // console.log(isDropdownVis);
  if (isDropdownVis) {
    isDropdownVis = false;
    $("#previousSearches").empty();
    $(".previousSearches").attr("id", "");
  }
})