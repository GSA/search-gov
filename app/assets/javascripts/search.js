/*
Instructions:
1. Place the following code in your template file
  <div id="search-gov-results" affiliate={affliate_name} key={}></div>
  You can find your affliate name and key in your search site admin dashbord.
2. Load search.js into your template file
*/

async function callAPI(url) {
    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`Response status: ${response.status}`);
      }

      const json = await response.json();
      //only the web results
      const data = json.web.results;
      return data;
    } catch (error) {
      console.error(error.message);
    }
  }

async function printResults(query, affilate, key){
    //clear the old results
    const list = document.getElementById('results-list');
    if (list) {
        list.remove();
    }

    //get and create html elements
    const div = document.getElementById('search-gov-results');
    const resultsList = document.createElement('ul');
    resultsList.id = "results-list";
    resultsList.classList.add("usa-list", "usa-list--unstyled");

    //Call the search API with custom params
    const data = await callAPI(
        `https://api.gsa.gov/technology/searchgov/v2/results/i14y?affiliate=${affilate}&access_key=${key}&query=${query}`
    );

    //create a link item for each result and append to ul
    data.forEach(result => {
        const listItem = document.createElement('li');
        const link = document.createElement("a");
        const snippet = document.createElement("p");
        link.href = result.url;
        link.textContent = result.title;
        snippet.textContent = result.snippet;
        listItem.appendChild(link);
        listItem.appendChild(snippet);
        resultsList.appendChild(listItem);
    });

    //append ul to div
    div.appendChild(resultsList);
}

function submitSearch(event) {
  event.preventDefault();
  //get query from text input
  const input = document.getElementById('search-input');
  const query = input.value;
  //get affilate from div attribute
  const div = document.getElementById('search-gov-results');
  const affliate = div.getAttribute("affiliate");
  const key = div.getAttribute("key");
  printResults(query, affliate, key);
}

function addSearchForm(){
    // Get container div and attributes
    const div = document.getElementById('search-gov-results');

    // create form
    const form = document.createElement('form');
    form.setAttribute('id', 'search-form');

    // create search input
    const searchBox = document.createElement('input');
    searchBox.setAttribute('type', 'text');
    searchBox.setAttribute('id', 'search-input');
    searchBox.setAttribute('class', 'usa-input');

    // create submit button
    const searchButton = document.createElement('button');
    searchButton.setAttribute('id', 'search-button');
    searchButton.setAttribute('class', 'usa-button');
    searchButton.type = 'submit';
    searchButton.textContent = "Search";

    // Action to perform when the form is submitted
    form.addEventListener("submit", submitSearch);

    // append elements
    div.appendChild(form);
    form.appendChild(searchBox);
    form.appendChild(searchButton);
}

addSearchForm();
