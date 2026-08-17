{{flutter_bootstrap_js}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      renderer: "html"
    });
    await appRunner.runApp();
  }
});
