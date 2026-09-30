enum CustomFieldModule {
  lead('Lead'),
  appointment('Appointment'),
  visit('Visit'),
  contact('Contact'),
  deal('Deal');

  final String apiValue;

  const CustomFieldModule(this.apiValue);
}
