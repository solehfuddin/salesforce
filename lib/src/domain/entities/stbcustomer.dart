class StbCustomer {
  String id, customerBillName, customerBillNumber, status, idFlag, customerCategoryCode,
  customerShipNumber, territoryId, area, taxCode, glIdFreight, partyId, customerId, 
  partySiteId, partyLocationId, addressId, siteUseId, billToSiteUseId, customerShipName,
  address2, address3, address4, city, postalCode, state, province, phone, contactPerson;
  String totalContract = '';
  bool ischecked = false;

  StbCustomer.fromJson(Map json):
    id = json['id'],
    customerBillName = json['customer_bill_name'],
    customerBillNumber = json['customer_bill_number'],
    status = json['status'],
    idFlag = json['id_flag'],
    customerCategoryCode = json['customer_category_code'],
    customerShipNumber = json['customer_ship_number'],
    territoryId = json['territory_id'],
    area = json['area'],
    taxCode = json['tax_code'],
    glIdFreight = json['gl_id_freight'],
    partyId = json['party_id'],
    customerId = json['customer_id'],
    partySiteId = json['party_site_id'],
    partyLocationId = json['party_location_id'],
    addressId = json['address_id'],
    siteUseId = json['site_use_id'],
    billToSiteUseId = json['bill_to_site_use_id'],
    customerShipName = json['customer_ship_name'],
    address2 = json['address2'],
    address3 = json['address3'],
    address4 = json['address4'],
    city = json['city'],
    postalCode = json['postal_code'],
    state = json['state'],
    province = json['province'],
    phone = json['phone'],
    contactPerson = json['contact_person'];

  Map toJson(){
    return {
      'id' : id,
      'customer_bill_name' : customerBillName,
      'customer_bill_number' : customerBillNumber,
      'status' : status,
      'id_flag' : idFlag,
      'customer_category_code' : customerCategoryCode,
      'customer_ship_number' : customerShipNumber,
      'territory_id' : territoryId,
      'area' : area,
      'tax_code' : taxCode,
      'gl_id_freight' : glIdFreight,
      'party_id' : partyId,
      'customer_id' : customerId,
      'party_site_id' : partySiteId,
      'party_location_id' : partyLocationId,
      'address_id' : addressId,
      'site_use_id' : siteUseId,
      'bill_to_site_use_id' : billToSiteUseId,
      'customer_ship_name' : customerShipName,
      'address2' : address2,
      'address3' : address3,
      'address4' : address4,
      'city' : city,
      'postal_code' : postalCode,
      'state' : state,
      'province' : province,
      'phone' : phone,
      'contact_person' : contactPerson,
    };
  }
}