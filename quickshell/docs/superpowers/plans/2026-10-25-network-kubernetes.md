# Separate network and Kubernetes

Goal: Restore local network graphs and give the cluster its own continuously updated bar module and multi-node, multi-namespace popup.

Architecture: Reuse NetworkDataProvider for sampled traffic and a bounded 180-second history. Extract cluster fetching/validation/health into a KubernetesDataProvider singleton shared by the new module and renamed popup. Use the existing BaseModule/BaseWidget registration and settings.

Constraints: No changes to lockscreen, Hyprland, or hypridle. No new dependencies. No hard-coded namespace filter. Completed jobs are not faults. Distinguish unavailable/stale data from healthy data. All views use existing theme fonts/colors, with concise functional labels.

- [x] Add network samples and history with reset handling on disconnect, interface changes and counter resets. Build independent down/up graphs.
- [x] Extract cluster validation and polling; build summaries from all namespaces and per-node pod assignments. Retain last response on errors while clearly marking it unavailable.
- [x] Create kubernetes module and popup; add node cards, namespace table/filter, problems, and pod/deployment/event details.
- [x] Register provider/widget and add kubernetes next to network in the active primary bar settings.
- [x] Verify actual endpoint schema, history boundaries, completed jobs, failures/staleness, namespace filtering and offscreen UI interactions/rendering. Run QML checks and review diff.

Verification: `python3 checks/network-kubernetes.py /tmp/kubernetes-info-final.json` passes 40 provider/UI assertions and renders both popups. Independent read-only review found no actionable defects. A separate real-provider run collected two valid samples from enp7s0. The running Quickshell instance reloaded and registered both network and kubernetes widgets/modules. The graph was extracted into registered Components/NetworkTrafficGraph.qml after the live reload exposed an inline-component type-cache issue. QML tooling retains known ShellScreen width/height and implicit ScrollView contentItem type warnings; runtime rendering succeeds.

Local settings.json is gitignored; its primary DP-2 bar now contains `network`, `kubernetes`, and `theme` in that order. No Hyprland or hypridle changes.
