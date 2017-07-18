const Elm = require('./Main.elm');
const Stylesheets = require('./Stylesheets.elm');

(function init() {
  const node = document.getElementById('main');
  const app = Elm.Main.embed(node);
})();

