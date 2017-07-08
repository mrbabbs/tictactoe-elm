import Elm from './Main.elm'
import Stylesheets from './Stylesheets.elm'

(function init() {
  const node = document.getElementById('main');
  const app = Elm.Main.embed(node);
})();

