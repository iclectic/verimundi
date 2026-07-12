// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Region {

 String get id; String get name; String get displayName; List<String> get countryCodes;
/// Create a copy of Region
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegionCopyWith<Region> get copyWith => _$RegionCopyWithImpl<Region>(this as Region, _$identity);

  /// Serializes this Region to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Region&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other.countryCodes, countryCodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayName,const DeepCollectionEquality().hash(countryCodes));

@override
String toString() {
  return 'Region(id: $id, name: $name, displayName: $displayName, countryCodes: $countryCodes)';
}


}

/// @nodoc
abstract mixin class $RegionCopyWith<$Res>  {
  factory $RegionCopyWith(Region value, $Res Function(Region) _then) = _$RegionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String displayName, List<String> countryCodes
});




}
/// @nodoc
class _$RegionCopyWithImpl<$Res>
    implements $RegionCopyWith<$Res> {
  _$RegionCopyWithImpl(this._self, this._then);

  final Region _self;
  final $Res Function(Region) _then;

/// Create a copy of Region
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? displayName = null,Object? countryCodes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,countryCodes: null == countryCodes ? _self.countryCodes : countryCodes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Region].
extension RegionPatterns on Region {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Region value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Region() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Region value)  $default,){
final _that = this;
switch (_that) {
case _Region():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Region value)?  $default,){
final _that = this;
switch (_that) {
case _Region() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String displayName,  List<String> countryCodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Region() when $default != null:
return $default(_that.id,_that.name,_that.displayName,_that.countryCodes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String displayName,  List<String> countryCodes)  $default,) {final _that = this;
switch (_that) {
case _Region():
return $default(_that.id,_that.name,_that.displayName,_that.countryCodes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String displayName,  List<String> countryCodes)?  $default,) {final _that = this;
switch (_that) {
case _Region() when $default != null:
return $default(_that.id,_that.name,_that.displayName,_that.countryCodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Region implements Region {
  const _Region({required this.id, required this.name, required this.displayName, required final  List<String> countryCodes}): _countryCodes = countryCodes;
  factory _Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);

@override final  String id;
@override final  String name;
@override final  String displayName;
 final  List<String> _countryCodes;
@override List<String> get countryCodes {
  if (_countryCodes is EqualUnmodifiableListView) return _countryCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_countryCodes);
}


/// Create a copy of Region
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegionCopyWith<_Region> get copyWith => __$RegionCopyWithImpl<_Region>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Region&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other._countryCodes, _countryCodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayName,const DeepCollectionEquality().hash(_countryCodes));

@override
String toString() {
  return 'Region(id: $id, name: $name, displayName: $displayName, countryCodes: $countryCodes)';
}


}

/// @nodoc
abstract mixin class _$RegionCopyWith<$Res> implements $RegionCopyWith<$Res> {
  factory _$RegionCopyWith(_Region value, $Res Function(_Region) _then) = __$RegionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String displayName, List<String> countryCodes
});




}
/// @nodoc
class __$RegionCopyWithImpl<$Res>
    implements _$RegionCopyWith<$Res> {
  __$RegionCopyWithImpl(this._self, this._then);

  final _Region _self;
  final $Res Function(_Region) _then;

/// Create a copy of Region
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? displayName = null,Object? countryCodes = null,}) {
  return _then(_Region(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,countryCodes: null == countryCodes ? _self._countryCodes : countryCodes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CountryNewsStatus {

 String get code; String get name; String get region; double get latitude; double get longitude; Severity get currentSeverity; int get activeStoryCount; int get positiveStoryCount; DateTime get lastUpdated;
/// Create a copy of CountryNewsStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountryNewsStatusCopyWith<CountryNewsStatus> get copyWith => _$CountryNewsStatusCopyWithImpl<CountryNewsStatus>(this as CountryNewsStatus, _$identity);

  /// Serializes this CountryNewsStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountryNewsStatus&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.region, region) || other.region == region)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.currentSeverity, currentSeverity) || other.currentSeverity == currentSeverity)&&(identical(other.activeStoryCount, activeStoryCount) || other.activeStoryCount == activeStoryCount)&&(identical(other.positiveStoryCount, positiveStoryCount) || other.positiveStoryCount == positiveStoryCount)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,region,latitude,longitude,currentSeverity,activeStoryCount,positiveStoryCount,lastUpdated);

@override
String toString() {
  return 'CountryNewsStatus(code: $code, name: $name, region: $region, latitude: $latitude, longitude: $longitude, currentSeverity: $currentSeverity, activeStoryCount: $activeStoryCount, positiveStoryCount: $positiveStoryCount, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $CountryNewsStatusCopyWith<$Res>  {
  factory $CountryNewsStatusCopyWith(CountryNewsStatus value, $Res Function(CountryNewsStatus) _then) = _$CountryNewsStatusCopyWithImpl;
@useResult
$Res call({
 String code, String name, String region, double latitude, double longitude, Severity currentSeverity, int activeStoryCount, int positiveStoryCount, DateTime lastUpdated
});




}
/// @nodoc
class _$CountryNewsStatusCopyWithImpl<$Res>
    implements $CountryNewsStatusCopyWith<$Res> {
  _$CountryNewsStatusCopyWithImpl(this._self, this._then);

  final CountryNewsStatus _self;
  final $Res Function(CountryNewsStatus) _then;

/// Create a copy of CountryNewsStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? region = null,Object? latitude = null,Object? longitude = null,Object? currentSeverity = null,Object? activeStoryCount = null,Object? positiveStoryCount = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,currentSeverity: null == currentSeverity ? _self.currentSeverity : currentSeverity // ignore: cast_nullable_to_non_nullable
as Severity,activeStoryCount: null == activeStoryCount ? _self.activeStoryCount : activeStoryCount // ignore: cast_nullable_to_non_nullable
as int,positiveStoryCount: null == positiveStoryCount ? _self.positiveStoryCount : positiveStoryCount // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CountryNewsStatus].
extension CountryNewsStatusPatterns on CountryNewsStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountryNewsStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountryNewsStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountryNewsStatus value)  $default,){
final _that = this;
switch (_that) {
case _CountryNewsStatus():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountryNewsStatus value)?  $default,){
final _that = this;
switch (_that) {
case _CountryNewsStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String region,  double latitude,  double longitude,  Severity currentSeverity,  int activeStoryCount,  int positiveStoryCount,  DateTime lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountryNewsStatus() when $default != null:
return $default(_that.code,_that.name,_that.region,_that.latitude,_that.longitude,_that.currentSeverity,_that.activeStoryCount,_that.positiveStoryCount,_that.lastUpdated);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String region,  double latitude,  double longitude,  Severity currentSeverity,  int activeStoryCount,  int positiveStoryCount,  DateTime lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _CountryNewsStatus():
return $default(_that.code,_that.name,_that.region,_that.latitude,_that.longitude,_that.currentSeverity,_that.activeStoryCount,_that.positiveStoryCount,_that.lastUpdated);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String region,  double latitude,  double longitude,  Severity currentSeverity,  int activeStoryCount,  int positiveStoryCount,  DateTime lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _CountryNewsStatus() when $default != null:
return $default(_that.code,_that.name,_that.region,_that.latitude,_that.longitude,_that.currentSeverity,_that.activeStoryCount,_that.positiveStoryCount,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CountryNewsStatus implements CountryNewsStatus {
  const _CountryNewsStatus({required this.code, required this.name, required this.region, required this.latitude, required this.longitude, required this.currentSeverity, required this.activeStoryCount, required this.positiveStoryCount, required this.lastUpdated});
  factory _CountryNewsStatus.fromJson(Map<String, dynamic> json) => _$CountryNewsStatusFromJson(json);

@override final  String code;
@override final  String name;
@override final  String region;
@override final  double latitude;
@override final  double longitude;
@override final  Severity currentSeverity;
@override final  int activeStoryCount;
@override final  int positiveStoryCount;
@override final  DateTime lastUpdated;

/// Create a copy of CountryNewsStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountryNewsStatusCopyWith<_CountryNewsStatus> get copyWith => __$CountryNewsStatusCopyWithImpl<_CountryNewsStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CountryNewsStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountryNewsStatus&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.region, region) || other.region == region)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.currentSeverity, currentSeverity) || other.currentSeverity == currentSeverity)&&(identical(other.activeStoryCount, activeStoryCount) || other.activeStoryCount == activeStoryCount)&&(identical(other.positiveStoryCount, positiveStoryCount) || other.positiveStoryCount == positiveStoryCount)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,region,latitude,longitude,currentSeverity,activeStoryCount,positiveStoryCount,lastUpdated);

@override
String toString() {
  return 'CountryNewsStatus(code: $code, name: $name, region: $region, latitude: $latitude, longitude: $longitude, currentSeverity: $currentSeverity, activeStoryCount: $activeStoryCount, positiveStoryCount: $positiveStoryCount, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$CountryNewsStatusCopyWith<$Res> implements $CountryNewsStatusCopyWith<$Res> {
  factory _$CountryNewsStatusCopyWith(_CountryNewsStatus value, $Res Function(_CountryNewsStatus) _then) = __$CountryNewsStatusCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String region, double latitude, double longitude, Severity currentSeverity, int activeStoryCount, int positiveStoryCount, DateTime lastUpdated
});




}
/// @nodoc
class __$CountryNewsStatusCopyWithImpl<$Res>
    implements _$CountryNewsStatusCopyWith<$Res> {
  __$CountryNewsStatusCopyWithImpl(this._self, this._then);

  final _CountryNewsStatus _self;
  final $Res Function(_CountryNewsStatus) _then;

/// Create a copy of CountryNewsStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? region = null,Object? latitude = null,Object? longitude = null,Object? currentSeverity = null,Object? activeStoryCount = null,Object? positiveStoryCount = null,Object? lastUpdated = null,}) {
  return _then(_CountryNewsStatus(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,currentSeverity: null == currentSeverity ? _self.currentSeverity : currentSeverity // ignore: cast_nullable_to_non_nullable
as Severity,activeStoryCount: null == activeStoryCount ? _self.activeStoryCount : activeStoryCount // ignore: cast_nullable_to_non_nullable
as int,positiveStoryCount: null == positiveStoryCount ? _self.positiveStoryCount : positiveStoryCount // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$NewsSource {

 String get id; String get name; String get articleUrl; String get publisherUrl; String get countryCode; String get languageCode; String get publicationType; bool get isLocalSource; DateTime get publishedAt; String? get author; CredibilityStatus get credibilityStatus; String get headline; String get coverageLevel;
/// Create a copy of NewsSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewsSourceCopyWith<NewsSource> get copyWith => _$NewsSourceCopyWithImpl<NewsSource>(this as NewsSource, _$identity);

  /// Serializes this NewsSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewsSource&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.articleUrl, articleUrl) || other.articleUrl == articleUrl)&&(identical(other.publisherUrl, publisherUrl) || other.publisherUrl == publisherUrl)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.publicationType, publicationType) || other.publicationType == publicationType)&&(identical(other.isLocalSource, isLocalSource) || other.isLocalSource == isLocalSource)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.credibilityStatus, credibilityStatus) || other.credibilityStatus == credibilityStatus)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverageLevel, coverageLevel) || other.coverageLevel == coverageLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,articleUrl,publisherUrl,countryCode,languageCode,publicationType,isLocalSource,publishedAt,author,credibilityStatus,headline,coverageLevel);

@override
String toString() {
  return 'NewsSource(id: $id, name: $name, articleUrl: $articleUrl, publisherUrl: $publisherUrl, countryCode: $countryCode, languageCode: $languageCode, publicationType: $publicationType, isLocalSource: $isLocalSource, publishedAt: $publishedAt, author: $author, credibilityStatus: $credibilityStatus, headline: $headline, coverageLevel: $coverageLevel)';
}


}

/// @nodoc
abstract mixin class $NewsSourceCopyWith<$Res>  {
  factory $NewsSourceCopyWith(NewsSource value, $Res Function(NewsSource) _then) = _$NewsSourceCopyWithImpl;
@useResult
$Res call({
 String id, String name, String articleUrl, String publisherUrl, String countryCode, String languageCode, String publicationType, bool isLocalSource, DateTime publishedAt, String? author, CredibilityStatus credibilityStatus, String headline, String coverageLevel
});




}
/// @nodoc
class _$NewsSourceCopyWithImpl<$Res>
    implements $NewsSourceCopyWith<$Res> {
  _$NewsSourceCopyWithImpl(this._self, this._then);

  final NewsSource _self;
  final $Res Function(NewsSource) _then;

/// Create a copy of NewsSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? articleUrl = null,Object? publisherUrl = null,Object? countryCode = null,Object? languageCode = null,Object? publicationType = null,Object? isLocalSource = null,Object? publishedAt = null,Object? author = freezed,Object? credibilityStatus = null,Object? headline = null,Object? coverageLevel = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,articleUrl: null == articleUrl ? _self.articleUrl : articleUrl // ignore: cast_nullable_to_non_nullable
as String,publisherUrl: null == publisherUrl ? _self.publisherUrl : publisherUrl // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,publicationType: null == publicationType ? _self.publicationType : publicationType // ignore: cast_nullable_to_non_nullable
as String,isLocalSource: null == isLocalSource ? _self.isLocalSource : isLocalSource // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,credibilityStatus: null == credibilityStatus ? _self.credibilityStatus : credibilityStatus // ignore: cast_nullable_to_non_nullable
as CredibilityStatus,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,coverageLevel: null == coverageLevel ? _self.coverageLevel : coverageLevel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NewsSource].
extension NewsSourcePatterns on NewsSource {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewsSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewsSource() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewsSource value)  $default,){
final _that = this;
switch (_that) {
case _NewsSource():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewsSource value)?  $default,){
final _that = this;
switch (_that) {
case _NewsSource() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String articleUrl,  String publisherUrl,  String countryCode,  String languageCode,  String publicationType,  bool isLocalSource,  DateTime publishedAt,  String? author,  CredibilityStatus credibilityStatus,  String headline,  String coverageLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewsSource() when $default != null:
return $default(_that.id,_that.name,_that.articleUrl,_that.publisherUrl,_that.countryCode,_that.languageCode,_that.publicationType,_that.isLocalSource,_that.publishedAt,_that.author,_that.credibilityStatus,_that.headline,_that.coverageLevel);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String articleUrl,  String publisherUrl,  String countryCode,  String languageCode,  String publicationType,  bool isLocalSource,  DateTime publishedAt,  String? author,  CredibilityStatus credibilityStatus,  String headline,  String coverageLevel)  $default,) {final _that = this;
switch (_that) {
case _NewsSource():
return $default(_that.id,_that.name,_that.articleUrl,_that.publisherUrl,_that.countryCode,_that.languageCode,_that.publicationType,_that.isLocalSource,_that.publishedAt,_that.author,_that.credibilityStatus,_that.headline,_that.coverageLevel);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String articleUrl,  String publisherUrl,  String countryCode,  String languageCode,  String publicationType,  bool isLocalSource,  DateTime publishedAt,  String? author,  CredibilityStatus credibilityStatus,  String headline,  String coverageLevel)?  $default,) {final _that = this;
switch (_that) {
case _NewsSource() when $default != null:
return $default(_that.id,_that.name,_that.articleUrl,_that.publisherUrl,_that.countryCode,_that.languageCode,_that.publicationType,_that.isLocalSource,_that.publishedAt,_that.author,_that.credibilityStatus,_that.headline,_that.coverageLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NewsSource implements NewsSource {
  const _NewsSource({required this.id, required this.name, required this.articleUrl, required this.publisherUrl, required this.countryCode, required this.languageCode, required this.publicationType, required this.isLocalSource, required this.publishedAt, this.author, required this.credibilityStatus, required this.headline, this.coverageLevel = 'regional'});
  factory _NewsSource.fromJson(Map<String, dynamic> json) => _$NewsSourceFromJson(json);

@override final  String id;
@override final  String name;
@override final  String articleUrl;
@override final  String publisherUrl;
@override final  String countryCode;
@override final  String languageCode;
@override final  String publicationType;
@override final  bool isLocalSource;
@override final  DateTime publishedAt;
@override final  String? author;
@override final  CredibilityStatus credibilityStatus;
@override final  String headline;
@override@JsonKey() final  String coverageLevel;

/// Create a copy of NewsSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewsSourceCopyWith<_NewsSource> get copyWith => __$NewsSourceCopyWithImpl<_NewsSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NewsSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewsSource&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.articleUrl, articleUrl) || other.articleUrl == articleUrl)&&(identical(other.publisherUrl, publisherUrl) || other.publisherUrl == publisherUrl)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.publicationType, publicationType) || other.publicationType == publicationType)&&(identical(other.isLocalSource, isLocalSource) || other.isLocalSource == isLocalSource)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.credibilityStatus, credibilityStatus) || other.credibilityStatus == credibilityStatus)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.coverageLevel, coverageLevel) || other.coverageLevel == coverageLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,articleUrl,publisherUrl,countryCode,languageCode,publicationType,isLocalSource,publishedAt,author,credibilityStatus,headline,coverageLevel);

@override
String toString() {
  return 'NewsSource(id: $id, name: $name, articleUrl: $articleUrl, publisherUrl: $publisherUrl, countryCode: $countryCode, languageCode: $languageCode, publicationType: $publicationType, isLocalSource: $isLocalSource, publishedAt: $publishedAt, author: $author, credibilityStatus: $credibilityStatus, headline: $headline, coverageLevel: $coverageLevel)';
}


}

/// @nodoc
abstract mixin class _$NewsSourceCopyWith<$Res> implements $NewsSourceCopyWith<$Res> {
  factory _$NewsSourceCopyWith(_NewsSource value, $Res Function(_NewsSource) _then) = __$NewsSourceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String articleUrl, String publisherUrl, String countryCode, String languageCode, String publicationType, bool isLocalSource, DateTime publishedAt, String? author, CredibilityStatus credibilityStatus, String headline, String coverageLevel
});




}
/// @nodoc
class __$NewsSourceCopyWithImpl<$Res>
    implements _$NewsSourceCopyWith<$Res> {
  __$NewsSourceCopyWithImpl(this._self, this._then);

  final _NewsSource _self;
  final $Res Function(_NewsSource) _then;

/// Create a copy of NewsSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? articleUrl = null,Object? publisherUrl = null,Object? countryCode = null,Object? languageCode = null,Object? publicationType = null,Object? isLocalSource = null,Object? publishedAt = null,Object? author = freezed,Object? credibilityStatus = null,Object? headline = null,Object? coverageLevel = null,}) {
  return _then(_NewsSource(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,articleUrl: null == articleUrl ? _self.articleUrl : articleUrl // ignore: cast_nullable_to_non_nullable
as String,publisherUrl: null == publisherUrl ? _self.publisherUrl : publisherUrl // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,publicationType: null == publicationType ? _self.publicationType : publicationType // ignore: cast_nullable_to_non_nullable
as String,isLocalSource: null == isLocalSource ? _self.isLocalSource : isLocalSource // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,credibilityStatus: null == credibilityStatus ? _self.credibilityStatus : credibilityStatus // ignore: cast_nullable_to_non_nullable
as CredibilityStatus,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,coverageLevel: null == coverageLevel ? _self.coverageLevel : coverageLevel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ConfirmedFact {

 String get text; List<String> get sourceIds;
/// Create a copy of ConfirmedFact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmedFactCopyWith<ConfirmedFact> get copyWith => _$ConfirmedFactCopyWithImpl<ConfirmedFact>(this as ConfirmedFact, _$identity);

  /// Serializes this ConfirmedFact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmedFact&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.sourceIds, sourceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(sourceIds));

@override
String toString() {
  return 'ConfirmedFact(text: $text, sourceIds: $sourceIds)';
}


}

/// @nodoc
abstract mixin class $ConfirmedFactCopyWith<$Res>  {
  factory $ConfirmedFactCopyWith(ConfirmedFact value, $Res Function(ConfirmedFact) _then) = _$ConfirmedFactCopyWithImpl;
@useResult
$Res call({
 String text, List<String> sourceIds
});




}
/// @nodoc
class _$ConfirmedFactCopyWithImpl<$Res>
    implements $ConfirmedFactCopyWith<$Res> {
  _$ConfirmedFactCopyWithImpl(this._self, this._then);

  final ConfirmedFact _self;
  final $Res Function(ConfirmedFact) _then;

/// Create a copy of ConfirmedFact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? sourceIds = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,sourceIds: null == sourceIds ? _self.sourceIds : sourceIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmedFact].
extension ConfirmedFactPatterns on ConfirmedFact {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmedFact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmedFact() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmedFact value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmedFact():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmedFact value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmedFact() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  List<String> sourceIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmedFact() when $default != null:
return $default(_that.text,_that.sourceIds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  List<String> sourceIds)  $default,) {final _that = this;
switch (_that) {
case _ConfirmedFact():
return $default(_that.text,_that.sourceIds);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  List<String> sourceIds)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmedFact() when $default != null:
return $default(_that.text,_that.sourceIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfirmedFact implements ConfirmedFact {
  const _ConfirmedFact({required this.text, required final  List<String> sourceIds}): _sourceIds = sourceIds;
  factory _ConfirmedFact.fromJson(Map<String, dynamic> json) => _$ConfirmedFactFromJson(json);

@override final  String text;
 final  List<String> _sourceIds;
@override List<String> get sourceIds {
  if (_sourceIds is EqualUnmodifiableListView) return _sourceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceIds);
}


/// Create a copy of ConfirmedFact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmedFactCopyWith<_ConfirmedFact> get copyWith => __$ConfirmedFactCopyWithImpl<_ConfirmedFact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmedFactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmedFact&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._sourceIds, _sourceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_sourceIds));

@override
String toString() {
  return 'ConfirmedFact(text: $text, sourceIds: $sourceIds)';
}


}

/// @nodoc
abstract mixin class _$ConfirmedFactCopyWith<$Res> implements $ConfirmedFactCopyWith<$Res> {
  factory _$ConfirmedFactCopyWith(_ConfirmedFact value, $Res Function(_ConfirmedFact) _then) = __$ConfirmedFactCopyWithImpl;
@override @useResult
$Res call({
 String text, List<String> sourceIds
});




}
/// @nodoc
class __$ConfirmedFactCopyWithImpl<$Res>
    implements _$ConfirmedFactCopyWith<$Res> {
  __$ConfirmedFactCopyWithImpl(this._self, this._then);

  final _ConfirmedFact _self;
  final $Res Function(_ConfirmedFact) _then;

/// Create a copy of ConfirmedFact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? sourceIds = null,}) {
  return _then(_ConfirmedFact(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,sourceIds: null == sourceIds ? _self._sourceIds : sourceIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$StoryCluster {

 String get id; String get headline; String get shortSummary; String get fullSummary; String get whyItMatters; List<String> get countryCodes; String get primaryCountryCode; String get region; StoryCategory get category; double get latitude; double get longitude; DateTime get firstPublishedAt; DateTime get lastUpdatedAt; Severity get severity; String get severityReason; Tone get tone; VerificationStatus get verificationStatus; double get confidenceScore; int get localSourceCount; int get regionalSourceCount; int get internationalSourceCount; double get underreportedScore; double get positiveImpactScore; List<NewsSource> get sourceArticles; List<ConfirmedFact> get confirmedFacts; List<String> get uncertainties; String? get imageUrl; bool get isSaved; bool get isDemoContent;
/// Create a copy of StoryCluster
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryClusterCopyWith<StoryCluster> get copyWith => _$StoryClusterCopyWithImpl<StoryCluster>(this as StoryCluster, _$identity);

  /// Serializes this StoryCluster to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryCluster&&(identical(other.id, id) || other.id == id)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.shortSummary, shortSummary) || other.shortSummary == shortSummary)&&(identical(other.fullSummary, fullSummary) || other.fullSummary == fullSummary)&&(identical(other.whyItMatters, whyItMatters) || other.whyItMatters == whyItMatters)&&const DeepCollectionEquality().equals(other.countryCodes, countryCodes)&&(identical(other.primaryCountryCode, primaryCountryCode) || other.primaryCountryCode == primaryCountryCode)&&(identical(other.region, region) || other.region == region)&&(identical(other.category, category) || other.category == category)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.firstPublishedAt, firstPublishedAt) || other.firstPublishedAt == firstPublishedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.severityReason, severityReason) || other.severityReason == severityReason)&&(identical(other.tone, tone) || other.tone == tone)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&(identical(other.localSourceCount, localSourceCount) || other.localSourceCount == localSourceCount)&&(identical(other.regionalSourceCount, regionalSourceCount) || other.regionalSourceCount == regionalSourceCount)&&(identical(other.internationalSourceCount, internationalSourceCount) || other.internationalSourceCount == internationalSourceCount)&&(identical(other.underreportedScore, underreportedScore) || other.underreportedScore == underreportedScore)&&(identical(other.positiveImpactScore, positiveImpactScore) || other.positiveImpactScore == positiveImpactScore)&&const DeepCollectionEquality().equals(other.sourceArticles, sourceArticles)&&const DeepCollectionEquality().equals(other.confirmedFacts, confirmedFacts)&&const DeepCollectionEquality().equals(other.uncertainties, uncertainties)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.isDemoContent, isDemoContent) || other.isDemoContent == isDemoContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,headline,shortSummary,fullSummary,whyItMatters,const DeepCollectionEquality().hash(countryCodes),primaryCountryCode,region,category,latitude,longitude,firstPublishedAt,lastUpdatedAt,severity,severityReason,tone,verificationStatus,confidenceScore,localSourceCount,regionalSourceCount,internationalSourceCount,underreportedScore,positiveImpactScore,const DeepCollectionEquality().hash(sourceArticles),const DeepCollectionEquality().hash(confirmedFacts),const DeepCollectionEquality().hash(uncertainties),imageUrl,isSaved,isDemoContent]);

@override
String toString() {
  return 'StoryCluster(id: $id, headline: $headline, shortSummary: $shortSummary, fullSummary: $fullSummary, whyItMatters: $whyItMatters, countryCodes: $countryCodes, primaryCountryCode: $primaryCountryCode, region: $region, category: $category, latitude: $latitude, longitude: $longitude, firstPublishedAt: $firstPublishedAt, lastUpdatedAt: $lastUpdatedAt, severity: $severity, severityReason: $severityReason, tone: $tone, verificationStatus: $verificationStatus, confidenceScore: $confidenceScore, localSourceCount: $localSourceCount, regionalSourceCount: $regionalSourceCount, internationalSourceCount: $internationalSourceCount, underreportedScore: $underreportedScore, positiveImpactScore: $positiveImpactScore, sourceArticles: $sourceArticles, confirmedFacts: $confirmedFacts, uncertainties: $uncertainties, imageUrl: $imageUrl, isSaved: $isSaved, isDemoContent: $isDemoContent)';
}


}

/// @nodoc
abstract mixin class $StoryClusterCopyWith<$Res>  {
  factory $StoryClusterCopyWith(StoryCluster value, $Res Function(StoryCluster) _then) = _$StoryClusterCopyWithImpl;
@useResult
$Res call({
 String id, String headline, String shortSummary, String fullSummary, String whyItMatters, List<String> countryCodes, String primaryCountryCode, String region, StoryCategory category, double latitude, double longitude, DateTime firstPublishedAt, DateTime lastUpdatedAt, Severity severity, String severityReason, Tone tone, VerificationStatus verificationStatus, double confidenceScore, int localSourceCount, int regionalSourceCount, int internationalSourceCount, double underreportedScore, double positiveImpactScore, List<NewsSource> sourceArticles, List<ConfirmedFact> confirmedFacts, List<String> uncertainties, String? imageUrl, bool isSaved, bool isDemoContent
});




}
/// @nodoc
class _$StoryClusterCopyWithImpl<$Res>
    implements $StoryClusterCopyWith<$Res> {
  _$StoryClusterCopyWithImpl(this._self, this._then);

  final StoryCluster _self;
  final $Res Function(StoryCluster) _then;

/// Create a copy of StoryCluster
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? headline = null,Object? shortSummary = null,Object? fullSummary = null,Object? whyItMatters = null,Object? countryCodes = null,Object? primaryCountryCode = null,Object? region = null,Object? category = null,Object? latitude = null,Object? longitude = null,Object? firstPublishedAt = null,Object? lastUpdatedAt = null,Object? severity = null,Object? severityReason = null,Object? tone = null,Object? verificationStatus = null,Object? confidenceScore = null,Object? localSourceCount = null,Object? regionalSourceCount = null,Object? internationalSourceCount = null,Object? underreportedScore = null,Object? positiveImpactScore = null,Object? sourceArticles = null,Object? confirmedFacts = null,Object? uncertainties = null,Object? imageUrl = freezed,Object? isSaved = null,Object? isDemoContent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,shortSummary: null == shortSummary ? _self.shortSummary : shortSummary // ignore: cast_nullable_to_non_nullable
as String,fullSummary: null == fullSummary ? _self.fullSummary : fullSummary // ignore: cast_nullable_to_non_nullable
as String,whyItMatters: null == whyItMatters ? _self.whyItMatters : whyItMatters // ignore: cast_nullable_to_non_nullable
as String,countryCodes: null == countryCodes ? _self.countryCodes : countryCodes // ignore: cast_nullable_to_non_nullable
as List<String>,primaryCountryCode: null == primaryCountryCode ? _self.primaryCountryCode : primaryCountryCode // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as StoryCategory,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,firstPublishedAt: null == firstPublishedAt ? _self.firstPublishedAt : firstPublishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as Severity,severityReason: null == severityReason ? _self.severityReason : severityReason // ignore: cast_nullable_to_non_nullable
as String,tone: null == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as Tone,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,localSourceCount: null == localSourceCount ? _self.localSourceCount : localSourceCount // ignore: cast_nullable_to_non_nullable
as int,regionalSourceCount: null == regionalSourceCount ? _self.regionalSourceCount : regionalSourceCount // ignore: cast_nullable_to_non_nullable
as int,internationalSourceCount: null == internationalSourceCount ? _self.internationalSourceCount : internationalSourceCount // ignore: cast_nullable_to_non_nullable
as int,underreportedScore: null == underreportedScore ? _self.underreportedScore : underreportedScore // ignore: cast_nullable_to_non_nullable
as double,positiveImpactScore: null == positiveImpactScore ? _self.positiveImpactScore : positiveImpactScore // ignore: cast_nullable_to_non_nullable
as double,sourceArticles: null == sourceArticles ? _self.sourceArticles : sourceArticles // ignore: cast_nullable_to_non_nullable
as List<NewsSource>,confirmedFacts: null == confirmedFacts ? _self.confirmedFacts : confirmedFacts // ignore: cast_nullable_to_non_nullable
as List<ConfirmedFact>,uncertainties: null == uncertainties ? _self.uncertainties : uncertainties // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,isDemoContent: null == isDemoContent ? _self.isDemoContent : isDemoContent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryCluster].
extension StoryClusterPatterns on StoryCluster {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryCluster value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryCluster() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryCluster value)  $default,){
final _that = this;
switch (_that) {
case _StoryCluster():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryCluster value)?  $default,){
final _that = this;
switch (_that) {
case _StoryCluster() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String headline,  String shortSummary,  String fullSummary,  String whyItMatters,  List<String> countryCodes,  String primaryCountryCode,  String region,  StoryCategory category,  double latitude,  double longitude,  DateTime firstPublishedAt,  DateTime lastUpdatedAt,  Severity severity,  String severityReason,  Tone tone,  VerificationStatus verificationStatus,  double confidenceScore,  int localSourceCount,  int regionalSourceCount,  int internationalSourceCount,  double underreportedScore,  double positiveImpactScore,  List<NewsSource> sourceArticles,  List<ConfirmedFact> confirmedFacts,  List<String> uncertainties,  String? imageUrl,  bool isSaved,  bool isDemoContent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryCluster() when $default != null:
return $default(_that.id,_that.headline,_that.shortSummary,_that.fullSummary,_that.whyItMatters,_that.countryCodes,_that.primaryCountryCode,_that.region,_that.category,_that.latitude,_that.longitude,_that.firstPublishedAt,_that.lastUpdatedAt,_that.severity,_that.severityReason,_that.tone,_that.verificationStatus,_that.confidenceScore,_that.localSourceCount,_that.regionalSourceCount,_that.internationalSourceCount,_that.underreportedScore,_that.positiveImpactScore,_that.sourceArticles,_that.confirmedFacts,_that.uncertainties,_that.imageUrl,_that.isSaved,_that.isDemoContent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String headline,  String shortSummary,  String fullSummary,  String whyItMatters,  List<String> countryCodes,  String primaryCountryCode,  String region,  StoryCategory category,  double latitude,  double longitude,  DateTime firstPublishedAt,  DateTime lastUpdatedAt,  Severity severity,  String severityReason,  Tone tone,  VerificationStatus verificationStatus,  double confidenceScore,  int localSourceCount,  int regionalSourceCount,  int internationalSourceCount,  double underreportedScore,  double positiveImpactScore,  List<NewsSource> sourceArticles,  List<ConfirmedFact> confirmedFacts,  List<String> uncertainties,  String? imageUrl,  bool isSaved,  bool isDemoContent)  $default,) {final _that = this;
switch (_that) {
case _StoryCluster():
return $default(_that.id,_that.headline,_that.shortSummary,_that.fullSummary,_that.whyItMatters,_that.countryCodes,_that.primaryCountryCode,_that.region,_that.category,_that.latitude,_that.longitude,_that.firstPublishedAt,_that.lastUpdatedAt,_that.severity,_that.severityReason,_that.tone,_that.verificationStatus,_that.confidenceScore,_that.localSourceCount,_that.regionalSourceCount,_that.internationalSourceCount,_that.underreportedScore,_that.positiveImpactScore,_that.sourceArticles,_that.confirmedFacts,_that.uncertainties,_that.imageUrl,_that.isSaved,_that.isDemoContent);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String headline,  String shortSummary,  String fullSummary,  String whyItMatters,  List<String> countryCodes,  String primaryCountryCode,  String region,  StoryCategory category,  double latitude,  double longitude,  DateTime firstPublishedAt,  DateTime lastUpdatedAt,  Severity severity,  String severityReason,  Tone tone,  VerificationStatus verificationStatus,  double confidenceScore,  int localSourceCount,  int regionalSourceCount,  int internationalSourceCount,  double underreportedScore,  double positiveImpactScore,  List<NewsSource> sourceArticles,  List<ConfirmedFact> confirmedFacts,  List<String> uncertainties,  String? imageUrl,  bool isSaved,  bool isDemoContent)?  $default,) {final _that = this;
switch (_that) {
case _StoryCluster() when $default != null:
return $default(_that.id,_that.headline,_that.shortSummary,_that.fullSummary,_that.whyItMatters,_that.countryCodes,_that.primaryCountryCode,_that.region,_that.category,_that.latitude,_that.longitude,_that.firstPublishedAt,_that.lastUpdatedAt,_that.severity,_that.severityReason,_that.tone,_that.verificationStatus,_that.confidenceScore,_that.localSourceCount,_that.regionalSourceCount,_that.internationalSourceCount,_that.underreportedScore,_that.positiveImpactScore,_that.sourceArticles,_that.confirmedFacts,_that.uncertainties,_that.imageUrl,_that.isSaved,_that.isDemoContent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoryCluster extends StoryCluster {
  const _StoryCluster({required this.id, required this.headline, required this.shortSummary, required this.fullSummary, required this.whyItMatters, required final  List<String> countryCodes, required this.primaryCountryCode, required this.region, required this.category, required this.latitude, required this.longitude, required this.firstPublishedAt, required this.lastUpdatedAt, required this.severity, required this.severityReason, required this.tone, required this.verificationStatus, required this.confidenceScore, required this.localSourceCount, required this.regionalSourceCount, required this.internationalSourceCount, required this.underreportedScore, required this.positiveImpactScore, required final  List<NewsSource> sourceArticles, required final  List<ConfirmedFact> confirmedFacts, required final  List<String> uncertainties, this.imageUrl, this.isSaved = false, required this.isDemoContent}): _countryCodes = countryCodes,_sourceArticles = sourceArticles,_confirmedFacts = confirmedFacts,_uncertainties = uncertainties,super._();
  factory _StoryCluster.fromJson(Map<String, dynamic> json) => _$StoryClusterFromJson(json);

@override final  String id;
@override final  String headline;
@override final  String shortSummary;
@override final  String fullSummary;
@override final  String whyItMatters;
 final  List<String> _countryCodes;
@override List<String> get countryCodes {
  if (_countryCodes is EqualUnmodifiableListView) return _countryCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_countryCodes);
}

@override final  String primaryCountryCode;
@override final  String region;
@override final  StoryCategory category;
@override final  double latitude;
@override final  double longitude;
@override final  DateTime firstPublishedAt;
@override final  DateTime lastUpdatedAt;
@override final  Severity severity;
@override final  String severityReason;
@override final  Tone tone;
@override final  VerificationStatus verificationStatus;
@override final  double confidenceScore;
@override final  int localSourceCount;
@override final  int regionalSourceCount;
@override final  int internationalSourceCount;
@override final  double underreportedScore;
@override final  double positiveImpactScore;
 final  List<NewsSource> _sourceArticles;
@override List<NewsSource> get sourceArticles {
  if (_sourceArticles is EqualUnmodifiableListView) return _sourceArticles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceArticles);
}

 final  List<ConfirmedFact> _confirmedFacts;
@override List<ConfirmedFact> get confirmedFacts {
  if (_confirmedFacts is EqualUnmodifiableListView) return _confirmedFacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_confirmedFacts);
}

 final  List<String> _uncertainties;
@override List<String> get uncertainties {
  if (_uncertainties is EqualUnmodifiableListView) return _uncertainties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uncertainties);
}

@override final  String? imageUrl;
@override@JsonKey() final  bool isSaved;
@override final  bool isDemoContent;

/// Create a copy of StoryCluster
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryClusterCopyWith<_StoryCluster> get copyWith => __$StoryClusterCopyWithImpl<_StoryCluster>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoryClusterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryCluster&&(identical(other.id, id) || other.id == id)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.shortSummary, shortSummary) || other.shortSummary == shortSummary)&&(identical(other.fullSummary, fullSummary) || other.fullSummary == fullSummary)&&(identical(other.whyItMatters, whyItMatters) || other.whyItMatters == whyItMatters)&&const DeepCollectionEquality().equals(other._countryCodes, _countryCodes)&&(identical(other.primaryCountryCode, primaryCountryCode) || other.primaryCountryCode == primaryCountryCode)&&(identical(other.region, region) || other.region == region)&&(identical(other.category, category) || other.category == category)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.firstPublishedAt, firstPublishedAt) || other.firstPublishedAt == firstPublishedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.severityReason, severityReason) || other.severityReason == severityReason)&&(identical(other.tone, tone) || other.tone == tone)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&(identical(other.localSourceCount, localSourceCount) || other.localSourceCount == localSourceCount)&&(identical(other.regionalSourceCount, regionalSourceCount) || other.regionalSourceCount == regionalSourceCount)&&(identical(other.internationalSourceCount, internationalSourceCount) || other.internationalSourceCount == internationalSourceCount)&&(identical(other.underreportedScore, underreportedScore) || other.underreportedScore == underreportedScore)&&(identical(other.positiveImpactScore, positiveImpactScore) || other.positiveImpactScore == positiveImpactScore)&&const DeepCollectionEquality().equals(other._sourceArticles, _sourceArticles)&&const DeepCollectionEquality().equals(other._confirmedFacts, _confirmedFacts)&&const DeepCollectionEquality().equals(other._uncertainties, _uncertainties)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.isDemoContent, isDemoContent) || other.isDemoContent == isDemoContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,headline,shortSummary,fullSummary,whyItMatters,const DeepCollectionEquality().hash(_countryCodes),primaryCountryCode,region,category,latitude,longitude,firstPublishedAt,lastUpdatedAt,severity,severityReason,tone,verificationStatus,confidenceScore,localSourceCount,regionalSourceCount,internationalSourceCount,underreportedScore,positiveImpactScore,const DeepCollectionEquality().hash(_sourceArticles),const DeepCollectionEquality().hash(_confirmedFacts),const DeepCollectionEquality().hash(_uncertainties),imageUrl,isSaved,isDemoContent]);

@override
String toString() {
  return 'StoryCluster(id: $id, headline: $headline, shortSummary: $shortSummary, fullSummary: $fullSummary, whyItMatters: $whyItMatters, countryCodes: $countryCodes, primaryCountryCode: $primaryCountryCode, region: $region, category: $category, latitude: $latitude, longitude: $longitude, firstPublishedAt: $firstPublishedAt, lastUpdatedAt: $lastUpdatedAt, severity: $severity, severityReason: $severityReason, tone: $tone, verificationStatus: $verificationStatus, confidenceScore: $confidenceScore, localSourceCount: $localSourceCount, regionalSourceCount: $regionalSourceCount, internationalSourceCount: $internationalSourceCount, underreportedScore: $underreportedScore, positiveImpactScore: $positiveImpactScore, sourceArticles: $sourceArticles, confirmedFacts: $confirmedFacts, uncertainties: $uncertainties, imageUrl: $imageUrl, isSaved: $isSaved, isDemoContent: $isDemoContent)';
}


}

/// @nodoc
abstract mixin class _$StoryClusterCopyWith<$Res> implements $StoryClusterCopyWith<$Res> {
  factory _$StoryClusterCopyWith(_StoryCluster value, $Res Function(_StoryCluster) _then) = __$StoryClusterCopyWithImpl;
@override @useResult
$Res call({
 String id, String headline, String shortSummary, String fullSummary, String whyItMatters, List<String> countryCodes, String primaryCountryCode, String region, StoryCategory category, double latitude, double longitude, DateTime firstPublishedAt, DateTime lastUpdatedAt, Severity severity, String severityReason, Tone tone, VerificationStatus verificationStatus, double confidenceScore, int localSourceCount, int regionalSourceCount, int internationalSourceCount, double underreportedScore, double positiveImpactScore, List<NewsSource> sourceArticles, List<ConfirmedFact> confirmedFacts, List<String> uncertainties, String? imageUrl, bool isSaved, bool isDemoContent
});




}
/// @nodoc
class __$StoryClusterCopyWithImpl<$Res>
    implements _$StoryClusterCopyWith<$Res> {
  __$StoryClusterCopyWithImpl(this._self, this._then);

  final _StoryCluster _self;
  final $Res Function(_StoryCluster) _then;

/// Create a copy of StoryCluster
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? headline = null,Object? shortSummary = null,Object? fullSummary = null,Object? whyItMatters = null,Object? countryCodes = null,Object? primaryCountryCode = null,Object? region = null,Object? category = null,Object? latitude = null,Object? longitude = null,Object? firstPublishedAt = null,Object? lastUpdatedAt = null,Object? severity = null,Object? severityReason = null,Object? tone = null,Object? verificationStatus = null,Object? confidenceScore = null,Object? localSourceCount = null,Object? regionalSourceCount = null,Object? internationalSourceCount = null,Object? underreportedScore = null,Object? positiveImpactScore = null,Object? sourceArticles = null,Object? confirmedFacts = null,Object? uncertainties = null,Object? imageUrl = freezed,Object? isSaved = null,Object? isDemoContent = null,}) {
  return _then(_StoryCluster(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,shortSummary: null == shortSummary ? _self.shortSummary : shortSummary // ignore: cast_nullable_to_non_nullable
as String,fullSummary: null == fullSummary ? _self.fullSummary : fullSummary // ignore: cast_nullable_to_non_nullable
as String,whyItMatters: null == whyItMatters ? _self.whyItMatters : whyItMatters // ignore: cast_nullable_to_non_nullable
as String,countryCodes: null == countryCodes ? _self._countryCodes : countryCodes // ignore: cast_nullable_to_non_nullable
as List<String>,primaryCountryCode: null == primaryCountryCode ? _self.primaryCountryCode : primaryCountryCode // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as StoryCategory,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,firstPublishedAt: null == firstPublishedAt ? _self.firstPublishedAt : firstPublishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as Severity,severityReason: null == severityReason ? _self.severityReason : severityReason // ignore: cast_nullable_to_non_nullable
as String,tone: null == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as Tone,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,localSourceCount: null == localSourceCount ? _self.localSourceCount : localSourceCount // ignore: cast_nullable_to_non_nullable
as int,regionalSourceCount: null == regionalSourceCount ? _self.regionalSourceCount : regionalSourceCount // ignore: cast_nullable_to_non_nullable
as int,internationalSourceCount: null == internationalSourceCount ? _self.internationalSourceCount : internationalSourceCount // ignore: cast_nullable_to_non_nullable
as int,underreportedScore: null == underreportedScore ? _self.underreportedScore : underreportedScore // ignore: cast_nullable_to_non_nullable
as double,positiveImpactScore: null == positiveImpactScore ? _self.positiveImpactScore : positiveImpactScore // ignore: cast_nullable_to_non_nullable
as double,sourceArticles: null == sourceArticles ? _self._sourceArticles : sourceArticles // ignore: cast_nullable_to_non_nullable
as List<NewsSource>,confirmedFacts: null == confirmedFacts ? _self._confirmedFacts : confirmedFacts // ignore: cast_nullable_to_non_nullable
as List<ConfirmedFact>,uncertainties: null == uncertainties ? _self._uncertainties : uncertainties // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,isDemoContent: null == isDemoContent ? _self.isDemoContent : isDemoContent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$StoryFilter {

 String? get query; String? get region; String? get countryCode; StoryCategory? get category; Severity? get severity; Tone? get tone; VerificationStatus? get verificationStatus; bool? get hasLocalCoverage; DateTime? get from; DateTime? get to;
/// Create a copy of StoryFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryFilterCopyWith<StoryFilter> get copyWith => _$StoryFilterCopyWithImpl<StoryFilter>(this as StoryFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.region, region) || other.region == region)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.category, category) || other.category == category)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.tone, tone) || other.tone == tone)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.hasLocalCoverage, hasLocalCoverage) || other.hasLocalCoverage == hasLocalCoverage)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,query,region,countryCode,category,severity,tone,verificationStatus,hasLocalCoverage,from,to);

@override
String toString() {
  return 'StoryFilter(query: $query, region: $region, countryCode: $countryCode, category: $category, severity: $severity, tone: $tone, verificationStatus: $verificationStatus, hasLocalCoverage: $hasLocalCoverage, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $StoryFilterCopyWith<$Res>  {
  factory $StoryFilterCopyWith(StoryFilter value, $Res Function(StoryFilter) _then) = _$StoryFilterCopyWithImpl;
@useResult
$Res call({
 String? query, String? region, String? countryCode, StoryCategory? category, Severity? severity, Tone? tone, VerificationStatus? verificationStatus, bool? hasLocalCoverage, DateTime? from, DateTime? to
});




}
/// @nodoc
class _$StoryFilterCopyWithImpl<$Res>
    implements $StoryFilterCopyWith<$Res> {
  _$StoryFilterCopyWithImpl(this._self, this._then);

  final StoryFilter _self;
  final $Res Function(StoryFilter) _then;

/// Create a copy of StoryFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = freezed,Object? region = freezed,Object? countryCode = freezed,Object? category = freezed,Object? severity = freezed,Object? tone = freezed,Object? verificationStatus = freezed,Object? hasLocalCoverage = freezed,Object? from = freezed,Object? to = freezed,}) {
  return _then(_self.copyWith(
query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as StoryCategory?,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as Severity?,tone: freezed == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as Tone?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus?,hasLocalCoverage: freezed == hasLocalCoverage ? _self.hasLocalCoverage : hasLocalCoverage // ignore: cast_nullable_to_non_nullable
as bool?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryFilter].
extension StoryFilterPatterns on StoryFilter {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryFilter() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryFilter value)  $default,){
final _that = this;
switch (_that) {
case _StoryFilter():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryFilter value)?  $default,){
final _that = this;
switch (_that) {
case _StoryFilter() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? query,  String? region,  String? countryCode,  StoryCategory? category,  Severity? severity,  Tone? tone,  VerificationStatus? verificationStatus,  bool? hasLocalCoverage,  DateTime? from,  DateTime? to)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryFilter() when $default != null:
return $default(_that.query,_that.region,_that.countryCode,_that.category,_that.severity,_that.tone,_that.verificationStatus,_that.hasLocalCoverage,_that.from,_that.to);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? query,  String? region,  String? countryCode,  StoryCategory? category,  Severity? severity,  Tone? tone,  VerificationStatus? verificationStatus,  bool? hasLocalCoverage,  DateTime? from,  DateTime? to)  $default,) {final _that = this;
switch (_that) {
case _StoryFilter():
return $default(_that.query,_that.region,_that.countryCode,_that.category,_that.severity,_that.tone,_that.verificationStatus,_that.hasLocalCoverage,_that.from,_that.to);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? query,  String? region,  String? countryCode,  StoryCategory? category,  Severity? severity,  Tone? tone,  VerificationStatus? verificationStatus,  bool? hasLocalCoverage,  DateTime? from,  DateTime? to)?  $default,) {final _that = this;
switch (_that) {
case _StoryFilter() when $default != null:
return $default(_that.query,_that.region,_that.countryCode,_that.category,_that.severity,_that.tone,_that.verificationStatus,_that.hasLocalCoverage,_that.from,_that.to);case _:
  return null;

}
}

}

/// @nodoc


class _StoryFilter implements StoryFilter {
  const _StoryFilter({this.query, this.region, this.countryCode, this.category, this.severity, this.tone, this.verificationStatus, this.hasLocalCoverage, this.from, this.to});
  

@override final  String? query;
@override final  String? region;
@override final  String? countryCode;
@override final  StoryCategory? category;
@override final  Severity? severity;
@override final  Tone? tone;
@override final  VerificationStatus? verificationStatus;
@override final  bool? hasLocalCoverage;
@override final  DateTime? from;
@override final  DateTime? to;

/// Create a copy of StoryFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryFilterCopyWith<_StoryFilter> get copyWith => __$StoryFilterCopyWithImpl<_StoryFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.region, region) || other.region == region)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.category, category) || other.category == category)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.tone, tone) || other.tone == tone)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.hasLocalCoverage, hasLocalCoverage) || other.hasLocalCoverage == hasLocalCoverage)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,query,region,countryCode,category,severity,tone,verificationStatus,hasLocalCoverage,from,to);

@override
String toString() {
  return 'StoryFilter(query: $query, region: $region, countryCode: $countryCode, category: $category, severity: $severity, tone: $tone, verificationStatus: $verificationStatus, hasLocalCoverage: $hasLocalCoverage, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class _$StoryFilterCopyWith<$Res> implements $StoryFilterCopyWith<$Res> {
  factory _$StoryFilterCopyWith(_StoryFilter value, $Res Function(_StoryFilter) _then) = __$StoryFilterCopyWithImpl;
@override @useResult
$Res call({
 String? query, String? region, String? countryCode, StoryCategory? category, Severity? severity, Tone? tone, VerificationStatus? verificationStatus, bool? hasLocalCoverage, DateTime? from, DateTime? to
});




}
/// @nodoc
class __$StoryFilterCopyWithImpl<$Res>
    implements _$StoryFilterCopyWith<$Res> {
  __$StoryFilterCopyWithImpl(this._self, this._then);

  final _StoryFilter _self;
  final $Res Function(_StoryFilter) _then;

/// Create a copy of StoryFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = freezed,Object? region = freezed,Object? countryCode = freezed,Object? category = freezed,Object? severity = freezed,Object? tone = freezed,Object? verificationStatus = freezed,Object? hasLocalCoverage = freezed,Object? from = freezed,Object? to = freezed,}) {
  return _then(_StoryFilter(
query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as StoryCategory?,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as Severity?,tone: freezed == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as Tone?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus?,hasLocalCoverage: freezed == hasLocalCoverage ? _self.hasLocalCoverage : hasLocalCoverage // ignore: cast_nullable_to_non_nullable
as bool?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$SavedStorySnapshot {

 String get storyId; DateTime get savedAt; String get headlineSnapshot; String get country; String get summarySnapshot; VerificationStatus get verificationStatus; int get lastKnownSourceCount;
/// Create a copy of SavedStorySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedStorySnapshotCopyWith<SavedStorySnapshot> get copyWith => _$SavedStorySnapshotCopyWithImpl<SavedStorySnapshot>(this as SavedStorySnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedStorySnapshot&&(identical(other.storyId, storyId) || other.storyId == storyId)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.headlineSnapshot, headlineSnapshot) || other.headlineSnapshot == headlineSnapshot)&&(identical(other.country, country) || other.country == country)&&(identical(other.summarySnapshot, summarySnapshot) || other.summarySnapshot == summarySnapshot)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.lastKnownSourceCount, lastKnownSourceCount) || other.lastKnownSourceCount == lastKnownSourceCount));
}


@override
int get hashCode => Object.hash(runtimeType,storyId,savedAt,headlineSnapshot,country,summarySnapshot,verificationStatus,lastKnownSourceCount);

@override
String toString() {
  return 'SavedStorySnapshot(storyId: $storyId, savedAt: $savedAt, headlineSnapshot: $headlineSnapshot, country: $country, summarySnapshot: $summarySnapshot, verificationStatus: $verificationStatus, lastKnownSourceCount: $lastKnownSourceCount)';
}


}

/// @nodoc
abstract mixin class $SavedStorySnapshotCopyWith<$Res>  {
  factory $SavedStorySnapshotCopyWith(SavedStorySnapshot value, $Res Function(SavedStorySnapshot) _then) = _$SavedStorySnapshotCopyWithImpl;
@useResult
$Res call({
 String storyId, DateTime savedAt, String headlineSnapshot, String country, String summarySnapshot, VerificationStatus verificationStatus, int lastKnownSourceCount
});




}
/// @nodoc
class _$SavedStorySnapshotCopyWithImpl<$Res>
    implements $SavedStorySnapshotCopyWith<$Res> {
  _$SavedStorySnapshotCopyWithImpl(this._self, this._then);

  final SavedStorySnapshot _self;
  final $Res Function(SavedStorySnapshot) _then;

/// Create a copy of SavedStorySnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? storyId = null,Object? savedAt = null,Object? headlineSnapshot = null,Object? country = null,Object? summarySnapshot = null,Object? verificationStatus = null,Object? lastKnownSourceCount = null,}) {
  return _then(_self.copyWith(
storyId: null == storyId ? _self.storyId : storyId // ignore: cast_nullable_to_non_nullable
as String,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,headlineSnapshot: null == headlineSnapshot ? _self.headlineSnapshot : headlineSnapshot // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,summarySnapshot: null == summarySnapshot ? _self.summarySnapshot : summarySnapshot // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,lastKnownSourceCount: null == lastKnownSourceCount ? _self.lastKnownSourceCount : lastKnownSourceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedStorySnapshot].
extension SavedStorySnapshotPatterns on SavedStorySnapshot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedStorySnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedStorySnapshot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedStorySnapshot value)  $default,){
final _that = this;
switch (_that) {
case _SavedStorySnapshot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedStorySnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _SavedStorySnapshot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String storyId,  DateTime savedAt,  String headlineSnapshot,  String country,  String summarySnapshot,  VerificationStatus verificationStatus,  int lastKnownSourceCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedStorySnapshot() when $default != null:
return $default(_that.storyId,_that.savedAt,_that.headlineSnapshot,_that.country,_that.summarySnapshot,_that.verificationStatus,_that.lastKnownSourceCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String storyId,  DateTime savedAt,  String headlineSnapshot,  String country,  String summarySnapshot,  VerificationStatus verificationStatus,  int lastKnownSourceCount)  $default,) {final _that = this;
switch (_that) {
case _SavedStorySnapshot():
return $default(_that.storyId,_that.savedAt,_that.headlineSnapshot,_that.country,_that.summarySnapshot,_that.verificationStatus,_that.lastKnownSourceCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String storyId,  DateTime savedAt,  String headlineSnapshot,  String country,  String summarySnapshot,  VerificationStatus verificationStatus,  int lastKnownSourceCount)?  $default,) {final _that = this;
switch (_that) {
case _SavedStorySnapshot() when $default != null:
return $default(_that.storyId,_that.savedAt,_that.headlineSnapshot,_that.country,_that.summarySnapshot,_that.verificationStatus,_that.lastKnownSourceCount);case _:
  return null;

}
}

}

/// @nodoc


class _SavedStorySnapshot implements SavedStorySnapshot {
  const _SavedStorySnapshot({required this.storyId, required this.savedAt, required this.headlineSnapshot, required this.country, required this.summarySnapshot, required this.verificationStatus, required this.lastKnownSourceCount});
  

@override final  String storyId;
@override final  DateTime savedAt;
@override final  String headlineSnapshot;
@override final  String country;
@override final  String summarySnapshot;
@override final  VerificationStatus verificationStatus;
@override final  int lastKnownSourceCount;

/// Create a copy of SavedStorySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedStorySnapshotCopyWith<_SavedStorySnapshot> get copyWith => __$SavedStorySnapshotCopyWithImpl<_SavedStorySnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedStorySnapshot&&(identical(other.storyId, storyId) || other.storyId == storyId)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.headlineSnapshot, headlineSnapshot) || other.headlineSnapshot == headlineSnapshot)&&(identical(other.country, country) || other.country == country)&&(identical(other.summarySnapshot, summarySnapshot) || other.summarySnapshot == summarySnapshot)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.lastKnownSourceCount, lastKnownSourceCount) || other.lastKnownSourceCount == lastKnownSourceCount));
}


@override
int get hashCode => Object.hash(runtimeType,storyId,savedAt,headlineSnapshot,country,summarySnapshot,verificationStatus,lastKnownSourceCount);

@override
String toString() {
  return 'SavedStorySnapshot(storyId: $storyId, savedAt: $savedAt, headlineSnapshot: $headlineSnapshot, country: $country, summarySnapshot: $summarySnapshot, verificationStatus: $verificationStatus, lastKnownSourceCount: $lastKnownSourceCount)';
}


}

/// @nodoc
abstract mixin class _$SavedStorySnapshotCopyWith<$Res> implements $SavedStorySnapshotCopyWith<$Res> {
  factory _$SavedStorySnapshotCopyWith(_SavedStorySnapshot value, $Res Function(_SavedStorySnapshot) _then) = __$SavedStorySnapshotCopyWithImpl;
@override @useResult
$Res call({
 String storyId, DateTime savedAt, String headlineSnapshot, String country, String summarySnapshot, VerificationStatus verificationStatus, int lastKnownSourceCount
});




}
/// @nodoc
class __$SavedStorySnapshotCopyWithImpl<$Res>
    implements _$SavedStorySnapshotCopyWith<$Res> {
  __$SavedStorySnapshotCopyWithImpl(this._self, this._then);

  final _SavedStorySnapshot _self;
  final $Res Function(_SavedStorySnapshot) _then;

/// Create a copy of SavedStorySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? storyId = null,Object? savedAt = null,Object? headlineSnapshot = null,Object? country = null,Object? summarySnapshot = null,Object? verificationStatus = null,Object? lastKnownSourceCount = null,}) {
  return _then(_SavedStorySnapshot(
storyId: null == storyId ? _self.storyId : storyId // ignore: cast_nullable_to_non_nullable
as String,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,headlineSnapshot: null == headlineSnapshot ? _self.headlineSnapshot : headlineSnapshot // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,summarySnapshot: null == summarySnapshot ? _self.summarySnapshot : summarySnapshot // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,lastKnownSourceCount: null == lastKnownSourceCount ? _self.lastKnownSourceCount : lastKnownSourceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AiStoryAnswer {

 String get answer; bool get insufficientEvidence; double get confidenceScore; List<String> get sourceIds; DateTime get generatedAt;
/// Create a copy of AiStoryAnswer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiStoryAnswerCopyWith<AiStoryAnswer> get copyWith => _$AiStoryAnswerCopyWithImpl<AiStoryAnswer>(this as AiStoryAnswer, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiStoryAnswer&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.insufficientEvidence, insufficientEvidence) || other.insufficientEvidence == insufficientEvidence)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&const DeepCollectionEquality().equals(other.sourceIds, sourceIds)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,answer,insufficientEvidence,confidenceScore,const DeepCollectionEquality().hash(sourceIds),generatedAt);

@override
String toString() {
  return 'AiStoryAnswer(answer: $answer, insufficientEvidence: $insufficientEvidence, confidenceScore: $confidenceScore, sourceIds: $sourceIds, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class $AiStoryAnswerCopyWith<$Res>  {
  factory $AiStoryAnswerCopyWith(AiStoryAnswer value, $Res Function(AiStoryAnswer) _then) = _$AiStoryAnswerCopyWithImpl;
@useResult
$Res call({
 String answer, bool insufficientEvidence, double confidenceScore, List<String> sourceIds, DateTime generatedAt
});




}
/// @nodoc
class _$AiStoryAnswerCopyWithImpl<$Res>
    implements $AiStoryAnswerCopyWith<$Res> {
  _$AiStoryAnswerCopyWithImpl(this._self, this._then);

  final AiStoryAnswer _self;
  final $Res Function(AiStoryAnswer) _then;

/// Create a copy of AiStoryAnswer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? answer = null,Object? insufficientEvidence = null,Object? confidenceScore = null,Object? sourceIds = null,Object? generatedAt = null,}) {
  return _then(_self.copyWith(
answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,insufficientEvidence: null == insufficientEvidence ? _self.insufficientEvidence : insufficientEvidence // ignore: cast_nullable_to_non_nullable
as bool,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,sourceIds: null == sourceIds ? _self.sourceIds : sourceIds // ignore: cast_nullable_to_non_nullable
as List<String>,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AiStoryAnswer].
extension AiStoryAnswerPatterns on AiStoryAnswer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiStoryAnswer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiStoryAnswer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiStoryAnswer value)  $default,){
final _that = this;
switch (_that) {
case _AiStoryAnswer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiStoryAnswer value)?  $default,){
final _that = this;
switch (_that) {
case _AiStoryAnswer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String answer,  bool insufficientEvidence,  double confidenceScore,  List<String> sourceIds,  DateTime generatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiStoryAnswer() when $default != null:
return $default(_that.answer,_that.insufficientEvidence,_that.confidenceScore,_that.sourceIds,_that.generatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String answer,  bool insufficientEvidence,  double confidenceScore,  List<String> sourceIds,  DateTime generatedAt)  $default,) {final _that = this;
switch (_that) {
case _AiStoryAnswer():
return $default(_that.answer,_that.insufficientEvidence,_that.confidenceScore,_that.sourceIds,_that.generatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String answer,  bool insufficientEvidence,  double confidenceScore,  List<String> sourceIds,  DateTime generatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AiStoryAnswer() when $default != null:
return $default(_that.answer,_that.insufficientEvidence,_that.confidenceScore,_that.sourceIds,_that.generatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AiStoryAnswer implements AiStoryAnswer {
  const _AiStoryAnswer({required this.answer, required this.insufficientEvidence, required this.confidenceScore, required final  List<String> sourceIds, required this.generatedAt}): _sourceIds = sourceIds;
  

@override final  String answer;
@override final  bool insufficientEvidence;
@override final  double confidenceScore;
 final  List<String> _sourceIds;
@override List<String> get sourceIds {
  if (_sourceIds is EqualUnmodifiableListView) return _sourceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceIds);
}

@override final  DateTime generatedAt;

/// Create a copy of AiStoryAnswer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiStoryAnswerCopyWith<_AiStoryAnswer> get copyWith => __$AiStoryAnswerCopyWithImpl<_AiStoryAnswer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiStoryAnswer&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.insufficientEvidence, insufficientEvidence) || other.insufficientEvidence == insufficientEvidence)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&const DeepCollectionEquality().equals(other._sourceIds, _sourceIds)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,answer,insufficientEvidence,confidenceScore,const DeepCollectionEquality().hash(_sourceIds),generatedAt);

@override
String toString() {
  return 'AiStoryAnswer(answer: $answer, insufficientEvidence: $insufficientEvidence, confidenceScore: $confidenceScore, sourceIds: $sourceIds, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class _$AiStoryAnswerCopyWith<$Res> implements $AiStoryAnswerCopyWith<$Res> {
  factory _$AiStoryAnswerCopyWith(_AiStoryAnswer value, $Res Function(_AiStoryAnswer) _then) = __$AiStoryAnswerCopyWithImpl;
@override @useResult
$Res call({
 String answer, bool insufficientEvidence, double confidenceScore, List<String> sourceIds, DateTime generatedAt
});




}
/// @nodoc
class __$AiStoryAnswerCopyWithImpl<$Res>
    implements _$AiStoryAnswerCopyWith<$Res> {
  __$AiStoryAnswerCopyWithImpl(this._self, this._then);

  final _AiStoryAnswer _self;
  final $Res Function(_AiStoryAnswer) _then;

/// Create a copy of AiStoryAnswer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? answer = null,Object? insufficientEvidence = null,Object? confidenceScore = null,Object? sourceIds = null,Object? generatedAt = null,}) {
  return _then(_AiStoryAnswer(
answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,insufficientEvidence: null == insufficientEvidence ? _self.insufficientEvidence : insufficientEvidence // ignore: cast_nullable_to_non_nullable
as bool,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,sourceIds: null == sourceIds ? _self._sourceIds : sourceIds // ignore: cast_nullable_to_non_nullable
as List<String>,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
