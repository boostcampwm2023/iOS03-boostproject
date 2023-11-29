import { Get, Optional, Patch, Query } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { UserProfileUpdateQuery } from './user.profile.update.query.dto';
import { UserProfileResponse } from './user.profile.response.dto';
import { UserProfileQuery } from './user.profile.query.dto';
import { UserFollowQuery } from './user.follow.query.dto';
import { UserProfileSimpleResponse } from './user.profile.simple.response.dto';
import { UserService } from './user.service';
import { AuthenticatedUser } from 'auth/auth.decorators';
import { Authentication } from 'auth/authentication.dto';
import { RestController } from 'utils/rest.controller.decorator';
import { UserFollowResponse } from './user.follow.response.dto';
import { UserProfileUpdateResponse } from './user.profile.update.response.dto';

@ApiTags('User')
@ApiBearerAuth('access-token')
@RestController('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @ApiOperation({
    summary: '유저 정보를 업데이트합니다.',
    description: `
# user/update

- 유저 정보를 업데이트합니다.
- 쿼리 파라미터로 name, introduce(자기소개), imageUrl(프로필 사진) 중 하나 이상을 설정할 수 있습니다.
- 응답 포맷은 email과 함께 수정 완료된 정보를 응답합니다.
`,
  })
  @ApiOkResponse({type: UserProfileUpdateResponse})
  @Patch('update')
  async update(
    @AuthenticatedUser() user: Authentication,
    @Query() userInfo: UserProfileUpdateQuery,
  ) {
    await this.userService.updateUserInfo(user, userInfo);
  }

  @ApiOperation({
    summary: '나의 정보 혹은 다른 유저의 정보를 불러옵니다.',
  })
  @ApiResponse({
    type: UserProfileResponse,
  })
  @Get('profile')
  async profile(
    @Optional()
    @Query()
    { email }: UserProfileQuery,
    @AuthenticatedUser()
    user: Authentication,
  ) {
    return this.userService.getUserProfile(email ?? user.email);
  }

  @ApiOperation({ summary: '팔로우 혹은 언팔로우' })
  @ApiOkResponse({ type: UserFollowResponse })
  @Patch('follow')
  async follow(
    @Query() { followee }: UserFollowQuery,
    @AuthenticatedUser() { email }: Authentication,
  ) {
    return await this.userService.follow(email, followee);
  }

  @ApiOperation({ summary: '팔로워 리스트' })
  @ApiResponse({ type: [UserProfileSimpleResponse] })
  @Get('followers')
  async followers(
    @Optional() @Query() otherUser: UserProfileQuery,
    @AuthenticatedUser() user: Authentication,
  ) {
    return await this.userService.getFollowers({ ...user, ...otherUser });
  }

  @ApiOperation({ summary: '팔로잉 리스트' })
  @ApiResponse({ type: [UserProfileSimpleResponse] })
  @Get('followees')
  async followings(
    @Optional() @Query() otherUser: UserProfileQuery,
    @AuthenticatedUser() user: Authentication,
  ) {
    return await this.userService.getFollowees({ ...user, ...otherUser });
  }
}
