class MapController extends GetxController {
  Completer<GoogleMapController> googleMapC = Completer();
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  var markers = RxSet<Marker>();
  var polygons = RxSet<Polygon>();
  var polylines = <Polyline>{}.obs;
  var polygonLatLngs = <LatLng>[].obs;

  //
  int polygonIdCounter = 1;
  int polylineIdCounter = 1;
  int makerIdCounter = 1;
  var initialLatlng = const LatLng(0.0, 0.0).obs;
  CameraPosition initialLocation =
      const CameraPosition(target: LatLng(0.0, 0.0));
  @override
  void onInit() async {
    super.onInit();

    Position position = await determinePosition();
    initialLocation = CameraPosition(
      target: initialLatlng(LatLng(position.latitude, position.longitude)),
      zoom: 14.4746,
    );
  }

  void setMarker(LatLng point) async {
    final String makerIdVal = 'marker_$makerIdCounter';
    makerIdCounter++;

    markers.add(
      Marker(
          anchor: const Offset(0.5, 0.5),
          markerId: MarkerId(makerIdVal),
          position: point,
          icon: await BitmapDescriptor.fromAssetImage(
              createLocalImageConfiguration(Get.context!),
              AppPngAssets.marker)),
    );
  }

  void setPolygon() {
    final String polygonIdVal = 'polygon_$polygonIdCounter';
    polygonIdCounter++;

    polygons.add(
      Polygon(
        strokeColor: AppColors.textYellow,
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 3,
        fillColor: Colors.yellow.withOpacity(0.4),
      ),
    );
  }

  void setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$polylineIdCounter';
    polylineIdCounter++;

    polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  Future<void> goToPlace(
    Map<String, dynamic> place,
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await googleMapC.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          25),
    );
    setMarker(LatLng(lat, lng));
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
