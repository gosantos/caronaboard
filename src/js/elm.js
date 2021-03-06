var app;
var connectFirebase;

require(["../app/Stylesheets.elm"], function(Stylesheet) {});

require(["../app/Main.elm"], function(Elm) {
  var rootNode = document.getElementById("app");
  rootNode.innerHTML = "";
  app = Elm.Main.embed(rootNode, getFlags());

  if (connectFirebase) connectFirebase(app);
});

require(["./firebase"], function(connect) {
  connectFirebase = connect;
  if (app) connectFirebase(app);
});

var getFlags = function() {
  var currentUser =
    Object.keys(localStorage)
      .filter(function(key) {
        return key.match(/firebase:authUser/);
      })
      .map(function(key) {
        return JSON.parse(localStorage.getItem(key));
      })
      .map(function(user) {
        return { id: user.uid };
      })[0] || null;

  var profile = null;
  profile = JSON.parse(localStorage.getItem("profile"));

  return {
    currentUser: currentUser,
    profile: profile
  };
};
