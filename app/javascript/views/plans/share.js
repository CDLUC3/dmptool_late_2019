import * as notifier from '../../utils/notificationHelper';
import { isObject, isString } from '../../utils/isType';

$(() => {
  $('#set_visibility [name="plan[visibility]"]').click((e) => {
    $(e.target).closest('form').submit();
  });
  $('#set_visibility').on('ajax:success', (e, data) => {
    if (isObject(data) && isString(data.msg)) {
      notifier.renderNotice(data.msg);
    }
  });
  $('#set_visibility').on('ajax:error', (e, xhr) => {
    if (isObject(xhr.responseJSON)) {
      notifier.renderAlert(xhr.responseJSON.msg);
    } else {
      notifier.renderAlert(`${xhr.statusCode} - ${xhr.statusText}`);
    }
  });

  $('#set_register').on('submit', (e) => {
    $('#set_register .progress').html('<p>Contacting the DMP Registry please wait ...</p>');
  });

  $('#set_register').on('ajax:success', (e, data) => {
    $('#set_register .progress').html('');
    if (isObject(data) && isString(data.msg)) {
      notifier.renderNotice(data.msg);
    }
  });
  $('#set_register').on('ajax:error', (e, xhr) => {
    $('#set_register .progress').html('');
    if (isObject(xhr.responseJSON)) {
      notifier.renderAlert(xhr.responseJSON.msg);
    } else {
      notifier.renderAlert(`${xhr.statusCode} - ${xhr.statusText}`);
    }
  });
});
