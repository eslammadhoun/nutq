import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:nutq/core/network/api_client.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/data/models/job_detail_response.dart';
import 'package:nutq/features/jobs/data/models/job_list_response.dart';
import 'package:nutq/features/jobs/data/models/job_response.dart';
import 'package:nutq/features/jobs/data/models/submit_job_request.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';

part 'jobs_api_service.g.dart';

/// Retrofit HTTP interface — typed responses
@RestApi()
abstract class JobsApiService {
  factory JobsApiService(Dio dio, {String baseUrl}) = _JobsApiService;

  @GET('/jobs')
  Future<HttpResponse<JobListResponse>> listJobs({
    @Query('cursor') String? cursor,
    @Query('limit') int limit = 20,
  });

  @POST('/jobs')
  Future<HttpResponse<JobResponse>> submitJob(@Body() SubmitJobRequest request);

  @GET('/jobs/{jobId}')
  Future<HttpResponse<JobDetailResponse>> getJob(@Path('jobId') String jobId);

  @POST('/jobs/{jobId}/cancel')
  Future<HttpResponse<JobResponse>> cancelJob(@Path('jobId') String jobId);

  @POST('/jobs/{jobId}/confirm')
  Future<HttpResponse<JobResponse>> confirmUpload(@Path('jobId') String jobId);
}

/// Datasource interface — all callers use this (ApiResult + typed models)
abstract interface class JobsDataSource {
  Future<ApiResult<JobListResponse>> listJobs({String? cursor, int limit});
  Future<ApiResult<JobResponse>> submitJob(SubmitJobRequest request);
  Future<ApiResult<JobDetailResponse>> getJob(String jobId);
  Future<ApiResult<JobResponse>> cancelJob(String jobId);
  Future<ApiResult<JobResponse>> confirmUpload(String jobId);

  /// Streams [file] to the presigned slot URL (PUT /dev-storage/{token}).
  /// The token in the URL authorizes the request; no bearer token needed.
  Future<ApiResult<void>> uploadToSlot(String uploadUrl, UploadFile file);
}

/// Implementation: wraps Retrofit + ApiClient for safe deserialization
class JobsDataSourceImpl implements JobsDataSource {
  JobsDataSourceImpl(this._apiClient, this._retrofit, this._dio);

  final ApiClient _apiClient;
  final JobsApiService _retrofit;
  final Dio _dio;

  @override
  Future<ApiResult<JobListResponse>> listJobs({
    String? cursor,
    int limit = 20,
  }) async {
    final res = await _apiClient.execute(
      () => _retrofit.listJobs(cursor: cursor, limit: limit),
    );
    return res.mapSuccess((http) => http.data);
  }

  @override
  Future<ApiResult<JobResponse>> submitJob(SubmitJobRequest request) async {
    final res = await _apiClient.execute(() => _retrofit.submitJob(request));
    return res.mapSuccess((http) => http.data);
  }

  @override
  Future<ApiResult<JobDetailResponse>> getJob(String jobId) async {
    final res = await _apiClient.execute(() => _retrofit.getJob(jobId));
    return res.mapSuccess((http) => http.data);
  }

  @override
  Future<ApiResult<JobResponse>> cancelJob(String jobId) async {
    final res = await _apiClient.execute(() => _retrofit.cancelJob(jobId));
    return res.mapSuccess((http) => http.data);
  }

  @override
  Future<ApiResult<JobResponse>> confirmUpload(String jobId) async {
    final res = await _apiClient.execute(() => _retrofit.confirmUpload(jobId));
    return res.mapSuccess((http) => http.data);
  }

  @override
  Future<ApiResult<void>> uploadToSlot(String uploadUrl, UploadFile file) {
    return _apiClient.execute<void>(() async {
      await _dio.put<dynamic>(
        _resolveAgainstBaseUrl(uploadUrl),
        data: File(file.path).openRead(),
        options: Options(
          headers: <String, String>{
            'content-type': file.contentType,
            'content-length': file.sizeBytes.toString(),
          },
        ),
      );
    });
  }

  /// upload_url comes back relative ("/v1/dev-storage/{token}"); resolve it
  /// against the API host so the /v1 prefix isn't doubled.
  String _resolveAgainstBaseUrl(String url) {
    if (!url.startsWith('/')) return url;
    final base = Uri.tryParse(_dio.options.baseUrl);
    if (base == null || !base.hasScheme || base.host.isEmpty) return url;
    return base.replace(path: url, query: null).toString();
  }
}
