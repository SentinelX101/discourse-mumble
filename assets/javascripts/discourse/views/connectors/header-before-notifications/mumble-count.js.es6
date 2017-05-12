export default Ember.Component.extend({
	tagName: '',
	isVirtual: true,
	templateName: Em.computed.alias("mumble-count")
});
