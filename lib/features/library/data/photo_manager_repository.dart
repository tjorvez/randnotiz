import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../weather/domain/weather.dart';
import '../domain/photo_repository.dart';

/// [PhotoRepository] on top of Android's MediaStore via photo_manager.
class PhotoManagerRepository implements PhotoRepository {
  PhotoManagerRepository();

  static const _requestOption = PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.image,
      mediaLocation: true,
    ),
  );

  AssetPathEntity? _all;
  final _changes = StreamController<void>.broadcast();
  bool _listening = false;

  PhotoAccess _map(PermissionState state) => switch (state) {
    PermissionState.authorized => PhotoAccess.full,
    PermissionState.limited => PhotoAccess.limited,
    _ => PhotoAccess.denied,
  };

  @override
  Future<PhotoAccess> currentAccess() async => _map(
    await PhotoManager.getPermissionState(requestOption: _requestOption),
  );

  @override
  Future<PhotoAccess> requestAccess() async {
    final access = _map(
      await PhotoManager.requestPermissionExtend(requestOption: _requestOption),
    );
    _all = null;
    return access;
  }

  @override
  Future<void> manageAccess() async {
    if (await currentAccess() == PhotoAccess.limited) {
      await PhotoManager.presentLimited(type: RequestType.image);
    } else {
      await PhotoManager.openSetting();
    }
    _all = null;
  }

  void _startListening() {
    if (_listening) return;
    _listening = true;
    PhotoManager.addChangeCallback((_) {
      _all = null;
      _changes.add(null);
    });
    unawaited(PhotoManager.startChangeNotify());
  }

  Future<AssetPathEntity?> _allPhotos() async {
    if (_all != null) return _all;
    final paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );
    return _all = paths.isEmpty ? null : paths.first;
  }

  @override
  Future<List<PhotoItem>> loadPage(int page, {int pageSize = 120}) async {
    final all = await _allPhotos();
    if (all == null) return const [];
    final assets = await all.getAssetListPaged(page: page, size: pageSize);
    return assets.map(_toItem).toList();
  }

  PhotoItem _toItem(AssetEntity a) => PhotoItem(
    id: a.id,
    createdAt: a.createDateTime,
    width: a.orientatedWidth,
    height: a.orientatedHeight,
  );

  @override
  Future<PhotoItem?> findById(String id) async {
    final asset = await AssetEntity.fromId(id);
    if (asset == null || asset.type != AssetType.image) return null;
    return _toItem(asset);
  }

  @override
  Future<GeoPoint?> locationOf(String id) async {
    try {
      final asset = await AssetEntity.fromId(id);
      final latLng = await asset?.latlngAsync();
      if (latLng == null) return null;
      final point = GeoPoint(latLng.latitude, latLng.longitude);
      return point.isValid ? point : null;
    } on Exception catch (e) {
      debugPrint('Location lookup failed: ${e.runtimeType}');
      return null;
    }
  }

  @override
  Future<Uint8List?> scaledJpeg(
    String id, {
    int maxSide = 800,
    int quality = 85,
  }) async {
    final asset = await AssetEntity.fromId(id);
    if (asset == null) return null;
    final w = asset.orientatedWidth;
    final h = asset.orientatedHeight;
    final scale = (w <= 0 || h <= 0) ? 1.0 : min(1.0, maxSide / max(w, h));
    final size = ThumbnailSize(
      max(1, (w > 0 ? w * scale : maxSide).round()),
      max(1, (h > 0 ? h * scale : maxSide).round()),
    );
    return asset.thumbnailDataWithSize(
      size,
      format: ThumbnailFormat.jpeg,
      quality: quality,
    );
  }

  @override
  ImageProvider imageFor(PhotoItem item, {int? size}) {
    final entity = AssetEntity(
      id: item.id,
      typeInt: AssetType.image.index,
      width: item.width,
      height: item.height,
    );
    if (size == null) {
      final longSide = max(item.width, item.height);
      final scale = longSide > 1600 ? 1600 / longSide : 1.0;
      return AssetEntityImageProvider(
        entity,
        isOriginal: false,
        thumbnailSize: ThumbnailSize(
          max(1, (item.width * scale).round()),
          max(1, (item.height * scale).round()),
        ),
      );
    }
    return AssetEntityImageProvider(
      entity,
      isOriginal: false,
      thumbnailSize: ThumbnailSize.square(size),
    );
  }

  @override
  Stream<void> get changes {
    _startListening();
    return _changes.stream;
  }
}
