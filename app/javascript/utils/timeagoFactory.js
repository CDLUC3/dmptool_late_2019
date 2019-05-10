import enUS from '../locale/en_US/timeago';

/* global timeago */
const TimeagoFactory = (() => {
  timeago.register('en_US', enUS);
  /*
    @param el - DOM element
    @returns
  */
  return {
    render: (el) => {
      timeago().render(el, 'en_US');
    },
  };
})();

export default TimeagoFactory;
