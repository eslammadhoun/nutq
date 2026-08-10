import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:nutq/features/jobs/data/models/job_models.dart';

part 'jobs_api_service.g.dart';

@RestApi()
abstract class JobsApiService {
  factory JobsApiService(Dio dio) = _JobsApiService;

  @GET('/jobs')
  Future<JobListResponseModel> listJobs({
    @Query('cursor') String? cursor,
    @Query('limit') int limit = 20,
  });

  @GET('/jobs/{jobId}')
  Future<JobModel> getJob(@Path('jobId') String jobId);

  @POST('/jobs')
  Future<JobModel> submitJob(@Body() SubmitJobRequestModel body);

  @POST('/jobs/{jobId}/cancel')
  Future<JobModel> cancelJob(@Path('jobId') String jobId);
}
