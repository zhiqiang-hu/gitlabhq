<script>
import { ApolloMutation } from 'vue-apollo';
import { GlTooltipDirective, GlIcon, GlLink, GlSafeHtmlDirective } from '@gitlab/ui';
import updateNoteMutation from '../../graphql/mutations/update_note.mutation.graphql';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';
import TimelineEntryItem from '~/vue_shared/components/notes/timeline_entry_item.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import DesignReplyForm from './design_reply_form.vue';
import { findNoteId, extractDesignNoteId } from '../../utils/design_management_utils';
import { hasErrors } from '../../utils/cache_update';

export default {
  components: {
    UserAvatarLink,
    TimelineEntryItem,
    TimeAgoTooltip,
    DesignReplyForm,
    ApolloMutation,
    GlIcon,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    SafeHtml: GlSafeHtmlDirective,
  },
  props: {
    note: {
      type: Object,
      required: true,
    },
    markdownPreviewPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      noteText: this.note.body,
      isEditing: false,
    };
  },
  computed: {
    author() {
      return this.note.author;
    },
    noteAnchorId() {
      return findNoteId(this.note.id);
    },
    isNoteLinked() {
      return extractDesignNoteId(this.$route.hash) === this.noteAnchorId;
    },
    mutationPayload() {
      return {
        id: this.note.id,
        body: this.noteText,
      };
    },
    isEditButtonVisible() {
      return !this.isEditing && this.note.userPermissions.adminNote;
    },
  },
  methods: {
    hideForm() {
      this.isEditing = false;
      this.noteText = this.note.body;
    },
    onDone({ data }) {
      this.hideForm();
      if (hasErrors(data.updateNote)) {
        this.$emit('error', data.errors[0]);
      }
    },
  },
  updateNoteMutation,
};
</script>

<template>
  <timeline-entry-item :id="`note_${noteAnchorId}`" class="design-note note-form">
    <user-avatar-link
      :link-href="author.webUrl"
      :img-src="author.avatarUrl"
      :img-alt="author.username"
      :img-size="40"
    />
    <div class="gl-display-flex gl-justify-content-space-between">
      <div>
        <gl-link
          v-once
          :href="author.webUrl"
          class="js-user-link"
          :data-user-id="author.id"
          :data-username="author.username"
        >
          <span class="note-header-author-name gl-font-weight-bold">{{ author.name }}</span>
          <span v-if="author.status_tooltip_html" v-safe-html="author.status_tooltip_html"></span>
          <span class="note-headline-light">@{{ author.username }}</span>
        </gl-link>
        <span class="note-headline-light note-headline-meta">
          <span class="system-note-message"> <slot></slot> </span>
          <gl-link
            class="note-timestamp system-note-separator gl-display-block gl-mb-2"
            :href="`#note_${noteAnchorId}`"
          >
            <time-ago-tooltip :time="note.createdAt" tooltip-placement="bottom" />
          </gl-link>
        </span>
      </div>
      <div class="gl-display-flex gl-align-items-baseline">
        <slot name="resolveDiscussion"></slot>
        <button
          v-if="isEditButtonVisible"
          v-gl-tooltip
          type="button"
          :title="__('Edit comment')"
          class="note-action-button js-note-edit btn btn-transparent qa-note-edit-button"
          @click="isEditing = true"
        >
          <gl-icon name="pencil" class="link-highlight" />
        </button>
      </div>
    </div>
    <template v-if="!isEditing">
      <div
        v-safe-html="note.bodyHtml"
        class="note-text js-note-text md"
        data-qa-selector="note_content"
      ></div>
      <slot name="resolvedStatus"></slot>
    </template>
    <apollo-mutation
      v-else
      #default="{ mutate, loading }"
      :mutation="$options.updateNoteMutation"
      :variables="{
        input: mutationPayload,
      }"
      @error="$emit('error', $event)"
      @done="onDone"
    >
      <design-reply-form
        v-model="noteText"
        :is-saving="loading"
        :markdown-preview-path="markdownPreviewPath"
        :is-new-comment="false"
        class="gl-mt-5"
        @submit-form="mutate"
        @cancel-form="hideForm"
      />
    </apollo-mutation>
  </timeline-entry-item>
</template>
