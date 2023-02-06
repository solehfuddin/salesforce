class Discount {
  String idDiscount, idCust, idContract, categoryId, prodDiv, prodCat, prodDesc, discount, status,
  startDateActive, endDateActive, dateAdded;

  Discount.fromJson(Map json):
   idDiscount   = json['id'],
   idCust       = json['id_customer'],
   idContract   = json['id_contract'],
   categoryId   = json['category_id'],
   prodDiv      = json['prod_div'],
   prodCat      = json['prodcat'],
   prodDesc     = json['prodcat_description'] ?? '-',
   discount     = json['discount'] ?? '-',
   status       = json['status'],
   startDateActive = json['start_date_active'],
   endDateActive   = json['end_date_active'],
   dateAdded    = json['date_added'];
}