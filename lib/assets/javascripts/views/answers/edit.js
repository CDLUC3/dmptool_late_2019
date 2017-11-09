import {
  isObject,
  isNumber,
  isString } from '../../utils/isType';
import { Tinymce } from '../../utils/tinymce';
import debounce from '../../utils/debounce';
import TimeagoFactory from '../../utils/timeagoFactory';

$(() => {
  const editorClass = 'tinymce_answer';
  const showSavingMessage = jQuery => jQuery.closest('.question-form').find('.saving-message').show();
  const hideSavingMessage = jQuery => jQuery.closest('.question-form').find('.saving-message').hide();
  const closestUnsavedMessage = jQuery => jQuery.closest('.question-form').find('.unsaved-message');
  const questionId = jQuery => jQuery.closest('.form-answer').attr('data-autosave');
  const isStale = jQuery => jQuery.closest('.question-form').find('.answer-locking').html().length !== 0;
  /*
   * A map of debounced functions, one for each input, textarea or select change at any
   * form with class form-answer. The key represents a question id and the value holds
   * the debounced function for a given input, textarea or select. Note, this map is
   * populated on demand, i.e. the first time a change is made at a given input, textarea
   * or select within the form, a new key-value should be created. Succesive times, the
   * debounced function should be retrieved instead.
   */
  const debounceMap = {};
  const autoSaving = (jQuery) => {
    if (!isStale(jQuery)) {
      jQuery.closest('.form-answer').trigger('submit');
    }
  };
  const doneCallback = (data, jQuery) => {
    const form = jQuery.closest('form');
    // Validation for the data object received
    if (isObject(data)) {
      if (isObject(data.question)) { // Object related to question within data received
        if (isNumber(data.question.id)) {
          if (isString(data.question.answer_status)) {
            $(`#answer-status-${data.question.id}`).html(data.question.answer_status);
            TimeagoFactory.render($('time.timeago'));
          }
          if (isString(data.question.locking)) { // When an answer is stale...
            detachEventHandlers(form); // eslint-disable-line no-use-before-define
            // Reflesh views for this context
            $(`#answer-locking-${data.question.id}`).html(data.question.locking);
            $(`#answer-form-${data.question.id}`).html(data.question.form);
            const newForm = $(`#answer-form-${data.question.id}`).find('form');
            attachEventHandlers(newForm); // eslint-disable-line no-use-before-define
          } else { // When answer is NOT stale...
            $(`#answer-locking-${data.question.id}`).html('');
            if (isNumber(data.question.answer_lock_version)) {
              form.find('#answer_lock_version').val(data.question.answer_lock_version);
            }
          }
        }
      }// End Object related to question within data received
      if (isObject(data.plan)) { // Object related to plan within data received
        if (isString(data.plan.progress)) {
          $('.progress').html(data.plan.progress);
        }
      }
      if (isObject(data.section)) { // Object related to section within data received
        if (isNumber(data.section.id)) {
          if (isString(data.section.progress)) {
            $(`.section-progress-${data.section.id}`).html(data.section.progress);
          }
        }
      }
    }
  };
  const failCallback = (error, jQuery) => {
    closestUnsavedMessage(jQuery).html(
      (isObject(error.responseJSON) && isString(error.responseJSON.detail)) ?
        error.responseJSON.detail : error.statusText).show();
  };
  const changeHandler = (e) => {
    const target = $(e.target);
    const id = questionId(target);
    if (!debounceMap[id]) {
      debounceMap[id] = debounce(autoSaving);
    }
    debounceMap[id](target);
  };
  const submitHandler = (e) => {
    e.preventDefault();
    const target = $(e.target);
    const form = target.closest('form');
    const id = questionId(target);
    if (debounceMap[id]) {
      // Cancels the delated execution of autoSaving
      // (e.g. user clicks the button before the delay is met)
      debounceMap[id].cancel();
    }
    $.ajax({
      method: form.attr('method'),
      url: form.attr('action'),
      data: form.serializeArray(),
      beforeSend: () => {
        showSavingMessage(target);
      },
      complete: () => {
        hideSavingMessage(target);
      },
    }).done((data) => {
      doneCallback(data, target);
    }).fail((error) => {
      failCallback(error, target);
    });
  };
  const blurHandler = (editor) => {
    const target = $(editor.getElement());
    const id = questionId(target);
    if (editor.isDirty()) {
      editor.save(); // Saves contents from editor to the textarea element
      if (!debounceMap[id]) {
        debounceMap[id] = debounce(autoSaving);
      }
      debounceMap[id](target);
    }
  };
  const focusHandler = (editor) => {
    const id = questionId($(editor.getElement()));
    if (debounceMap[id]) {
      /* Cancels the delayed execution of autoSaving, either because user
       * transitioned from an option_based question to the comment or
       * because the target element triggered blur and focus before
       * the delayed execution of autoSaving.
      */
      debounceMap[id].cancel();
    }
  };
  const formHandlers = ({ jQuery, attachment = 'off' }) => {
    // Listeners to change and submit for a form
    jQuery[attachment]('change', changeHandler);
    jQuery[attachment]('submit', submitHandler);
  };
  const editorHandlers = (editor) => {
    // Listeners to blur and focus events for a tinymce instance
    editor.on('Blur', () => blurHandler(editor));
    editor.on('Focus', () => focusHandler(editor));
  };
    /*
    Detaches events from a specific form including its tinymce editor
    @param { objecg } - jQueryForm to remove events
  */
  const detachEventHandlers = (jQueryForm) => {
    formHandlers({ jQuery: jQueryForm, attachment: 'off' });
    const tinymceId = jQueryForm.find(`.${editorClass}`).attr('id');
    Tinymce.destroyEditorById(tinymceId);
  };
  /*
    Attaches events for a specific form including its tinymce editor
    @param { objecg } - jQueryForm to add events
  */
  const attachEventHandlers = (jQueryForm) => {
    formHandlers({ jQuery: jQueryForm, attachment: 'on' });
    const tinymceId = jQueryForm.find(`.${editorClass}`).attr('id');
    Tinymce.init({ selector: `#${tinymceId}` });
    editorHandlers(Tinymce.findEditorById(tinymceId));
  };
  TimeagoFactory.render($('time.timeago'));
  Tinymce.init({ selector: `.${editorClass}` });
  Tinymce.findEditorsByClassName(editorClass).forEach(editorHandlers);
  formHandlers({ jQuery: $('.form-answer'), attachment: 'on' });
});