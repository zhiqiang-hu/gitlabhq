<script>
import { __, sprintf } from '~/locale';

export default {
  props: {
    user: {
      type: Object,
      required: true,
    },
    imgSize: {
      type: Number,
      required: true,
    },
    issuableType: {
      type: String,
      required: false,
      default: 'issue',
    },
  },
  computed: {
    assigneeAlt() {
      return sprintf(__("%{userName}'s avatar"), { userName: this.user.name });
    },
    avatarUrl() {
      return (
        this.user.avatarUrl || this.user.avatar || this.user.avatar_url || gon.default_avatar_url
      );
    },
    isMergeRequest() {
      return this.issuableType === 'merge_request';
    },
    hasMergeIcon() {
      return this.isMergeRequest && !this.user.can_merge;
    },
  },
};
</script>

<template>
  <span class="position-relative">
    <img
      :alt="assigneeAlt"
      :src="avatarUrl"
      :width="imgSize"
      :class="`s${imgSize}`"
      class="avatar avatar-inline m-0"
      data-qa-selector="avatar_image"
    />
    <i v-if="hasMergeIcon" aria-hidden="true" class="fa fa-exclamation-triangle merge-icon"></i>
  </span>
</template>
