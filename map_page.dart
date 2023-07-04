class HomePage extends GetView<MapController> {
  HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Obx(
              () => GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: controller.markers.value,
                polygons: controller.polygons.value,
                polylines: controller.polylines.value,
                onTap: (point) {
                  controller.polygonLatLngs.add(point);
                  controller.setMarker(point);
                  controller.setPolygon();
                },
                mapType: MapType.satellite,
                onCameraMove: (position) {},
                onCameraIdle: () {},
                initialCameraPosition: controller.initialLocation,
                onMapCreated: (GoogleMapController googleMap) {
                  controller.googleMapC.complete(googleMap);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
