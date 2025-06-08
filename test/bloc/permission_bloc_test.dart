import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/permission.dart';
import 'package:smart_home_app/bloc/permission/permission_bloc.dart';
import 'package:smart_home_app/bloc/permission/permission_event.dart';
import 'package:smart_home_app/bloc/permission/permission_state.dart';

// Mocks
class MockApiClient extends Mock implements ApiClient {}

void main() {
  late PermissionBloc permissionBloc;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    permissionBloc = PermissionBloc(mockApiClient);
    // Register fallback values for events used in `add`
    registerFallbackValue(const LoadPermissions(''));
  });

  tearDown(() {
    permissionBloc.close();
  });

  const tDeviceId = 'device1';
  final tPermissions = [
    const UserPermission(id: 'p1', userId: 'user2', username: 'bob', permissionLevel: PermissionLevel.usable),
  ];
  final tPermissionsResponse = Response(
    requestOptions: RequestOptions(path: ''),
    data: [
      {'id': 'p1', 'user': {'id': 'user2', 'username': 'bob'}, 'permission_level': 'usable'}
    ],
  );

  test('initial state is PermissionInitial', () {
    expect(permissionBloc.state, PermissionInitial());
  });

  group('LoadPermissions', () {
    blocTest<PermissionBloc, PermissionState>(
      'emits [PermissionLoadInProgress, PermissionLoadSuccess] when successful',
      build: () {
        when(() => mockApiClient.getDevicePermissions(tDeviceId)).thenAnswer((_) async => tPermissionsResponse);
        return permissionBloc;
      },
      act: (bloc) => bloc.add(const LoadPermissions(tDeviceId)),
      expect: () => [
        PermissionLoadInProgress(),
        PermissionLoadSuccess(tPermissions),
      ],
    );

    blocTest<PermissionBloc, PermissionState>(
      'emits [PermissionLoadInProgress, PermissionLoadFailure] when fails',
      build: () {
        when(() => mockApiClient.getDevicePermissions(any())).thenThrow(Exception());
        return permissionBloc;
      },
      act: (bloc) => bloc.add(const LoadPermissions(tDeviceId)),
      expect: () => [
        PermissionLoadInProgress(),
        const PermissionLoadFailure('Failed to load permissions.'),
      ],
    );
  });

  group('ShareDevice', () {
    const tUserId = 'user3';
    const tRole = 'configurable';

    blocTest<PermissionBloc, PermissionState>(
      'emits [PermissionUpdateInProgress, PermissionUpdateSuccess] and reloads permissions',
      build: () {
        when(() => mockApiClient.shareDevice(tDeviceId, tUserId, tRole)).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '')));
        when(() => mockApiClient.getDevicePermissions(tDeviceId)).thenAnswer((_) async => tPermissionsResponse);
        return permissionBloc;
      },
      act: (bloc) => bloc.add(const ShareDevice(deviceId: tDeviceId, userId: tUserId, role: tRole)),
      expect: () => [
        PermissionUpdateInProgress(),
        const PermissionUpdateSuccess('Device shared successfully.'),
      ],
    );
  });

  group('RevokePermission', () {
    const tPermissionId = 'p1';

    blocTest<PermissionBloc, PermissionState>(
      'emits [PermissionUpdateInProgress, PermissionUpdateSuccess]',
      build: () {
        when(() => mockApiClient.revokePermission(tPermissionId)).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '')));
        return permissionBloc;
      },
      act: (bloc) => bloc.add(const RevokePermission(tPermissionId)),
      expect: () => [
        PermissionUpdateInProgress(),
        const PermissionUpdateSuccess('Permission revoked successfully.'),
      ],
    );

    blocTest<PermissionBloc, PermissionState>(
      'emits [PermissionUpdateInProgress, PermissionUpdateFailure] when fails',
      build: () {
        when(() => mockApiClient.revokePermission(any())).thenThrow(Exception());
        return permissionBloc;
      },
      act: (bloc) => bloc.add(const RevokePermission(tPermissionId)),
      expect: () => [
        PermissionUpdateInProgress(),
        const PermissionUpdateFailure('Failed to revoke permission.'),
      ],
    );
  });
} 