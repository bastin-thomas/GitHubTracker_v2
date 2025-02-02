import 'package:git_hub_tracker/core/model/github_library/event/payload/github_event_payload_create.dart';
import 'package:git_hub_tracker/core/model/github_library/event/payload/github_event_payload_fork.dart';
import 'package:git_hub_tracker/core/model/github_library/event/payload/github_event_payload_issue.dart';
import 'package:git_hub_tracker/core/model/github_library/event/payload/github_event_payload_issuecomment.dart';
import 'package:git_hub_tracker/core/model/github_library/event/payload/github_event_payload_public.dart';
import 'package:git_hub_tracker/core/model/github_library/event/payload/github_event_payload_watch.dart';
import 'package:git_hub_tracker/core/model/github_library/event/payload/payload_subtypes/github_event_actor.dart';
import 'package:git_hub_tracker/core/model/github_library/event/payload/payload_subtypes/github_event_repo.dart';
import 'package:git_hub_tracker/core/model/github_library/event/payload/github_event_payload.dart';
import 'package:git_hub_tracker/core/model/github_library/event/payload/github_event_payload_push.dart';
import 'package:git_hub_tracker/core/logic/utils.dart';

import 'payload/github_event_payload_delete.dart';


class GitHubEvent {
  late int id;
  late String type;
  late GitHubEventActor actor;
  late GitHubEventRepo repo;

  late GitHubEventPayload payload;

  late bool public;
  late DateTime created_at;


  GitHubEvent(Map<String, dynamic> content){
    id = int.parse(content["id"] == null ? '-1' : content['id']!);
    type = content["type"] == null ? 'unkown' : content['type']!;
    actor = GitHubEventActor(content["actor"] == null ? {} : content['actor']!);
    repo = GitHubEventRepo(content["repo"] == null ? {} : content['repo']!);

    public = content["public"] == null ? true : content['public']!;
    created_at = TimeConverter(content["created_at"]);

    if(type == GitHubEventPayload.PUSH){
      payload = GitHubEventPayloadPush(type, content['payload']);
    } else if(type == GitHubEventPayload.ISSUE_COMMENT){
      payload = GitHubEventPayloadIssueComment(type, content['payload']);
    } else if(type == GitHubEventPayload.WATCH){
      payload = GitHubEventPayloadWatch(type, content['payload']);
    } else if(type == GitHubEventPayload.ISSUE){
      payload = GitHubEventPayloadIssue(type, content['payload']);
    } else if(type == GitHubEventPayload.CREATE) {
      payload = GitHubEventPayloadCreate(type, content['payload']);
    } else if(type == GitHubEventPayload.DELETE){
      payload = GitHubEventPayloadDelete(type, content['payload']);
    } else if(type == GitHubEventPayload.PUBLIC){
      payload = GitHubEventPayloadPublic(type, content);
    } else if(type == GitHubEventPayload.FORK){
      payload = GitHubEventPayloadFork(type, content['payload']);
    } else {
      payload = GitHubEventPayload(type, content['payload']);
    }
  }

  @override
  String toString() {
    return '$id, $actor, $repo, $payload';
  }
}