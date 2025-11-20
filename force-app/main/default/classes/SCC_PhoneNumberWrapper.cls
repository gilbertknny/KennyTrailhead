public class SCC_PhoneNumberWrapper {
	public class AdditionalData {
		public String namaLengkapIbuKandung {get;set;} 
		public String nominalPendapatanPerBulan {get;set;} 

		public AdditionalData(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'namaLengkapIbuKandung') {
							namaLengkapIbuKandung = parser.getText();
						} else if (text == 'nominalPendapatanPerBulan') {
							nominalPendapatanPerBulan = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'AdditionalData consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Response {
		public List<CustomerData> customerData {get;set;} 

		public Response(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'customerData') {
							customerData = arrayOfCustomerData(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Response consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CardHolderData {
		public String limitKartuKredit {get;set;} 
		public String expiredKartu {get;set;} 
		public String tanggalCetakCycle {get;set;} 
		public String tanggalJatuhTempo {get;set;} 
		public String sisaLimitKartu {get;set;} 
		public String limitTarikTunaiKartu {get;set;} 
		public String sisaLimitTarikTunaiKartu {get;set;} 
		public String limitCicilanKartu {get;set;} 
		public String sisaLimitCicilanKartu {get;set;} 
		public String customerNumber {get;set;} 
		public String tanggalTerakhirMaintenanceKartu {get;set;} 
		public String namaCetakKartu {get;set;} 

		public CardHolderData(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'limitKartuKredit') {
							limitKartuKredit = parser.getText();
						} else if (text == 'expiredKartu') {
							expiredKartu = parser.getText();
						} else if (text == 'tanggalCetakCycle') {
							tanggalCetakCycle = parser.getText();
						} else if (text == 'tanggalJatuhTempo') {
							tanggalJatuhTempo = parser.getText();
						} else if (text == 'sisaLimitKartu') {
							sisaLimitKartu = parser.getText();
						} else if (text == 'limitTarikTunaiKartu') {
							limitTarikTunaiKartu = parser.getText();
						} else if (text == 'sisaLimitTarikTunaiKartu') {
							sisaLimitTarikTunaiKartu = parser.getText();
						} else if (text == 'limitCicilanKartu') {
							limitCicilanKartu = parser.getText();
						} else if (text == 'sisaLimitCicilanKartu') {
							sisaLimitCicilanKartu = parser.getText();
						} else if (text == 'customerNumber') {
							customerNumber = parser.getText();
						} else if (text == 'tanggalTerakhirMaintenanceKartu') {
							tanggalTerakhirMaintenanceKartu = parser.getText();
						} else if (text == 'namaCetakKartu') {
							namaCetakKartu = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CardHolderData consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public Response response {get;set;} 

	public SCC_PhoneNumberWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'response') {
						response = new Response(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Loan {
		public String acctno {get;set;} 
		public Double balance {get;set;} 
		public String cifno {get;set;} 
		public String product {get;set;} 
		public String productDescription {get;set;} 
		public String productType {get;set;} 
		public String status {get;set;} 

		public Loan(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'acctno') {
							acctno = parser.getText();
						} else if (text == 'balance') {
							balance = parser.getDoubleValue();
						} else if (text == 'cifno') {
							cifno = parser.getText();
						} else if (text == 'product') {
							product = parser.getText();
						} else if (text == 'productDescription') {
							productDescription = parser.getText();
						} else if (text == 'productType') {
							productType = parser.getText();
						} else if (text == 'status') {
							status = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Loan consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CustomerData {
		public String namaDepan {get;set;} 
		public String namaTengah {get;set;} 
		public String namaBelakang {get;set;} 
		public String nomorHandphoneTerdaftar {get;set;} 
		public String nomorTelephoneKerabatTidakSerumah {get;set;} 
		public String nomorTelephoneRumah {get;set;} 
		public String nomorTelephoneKantor {get;set;} 
		public String namaKerabatTidakSerumah {get;set;} 
		public String nomorNik {get;set;} 
		public String nomorNpwp {get;set;} 
		public String sisaLimitNasabah {get;set;} 
		public String limitTarikTunaiNasabah {get;set;} 
		public String sisaLimitTarikTunaiNasabah {get;set;} 
		public String limitCicilanNasabah {get;set;} 
		public String sisaLimitCicilanNasabah {get;set;} 
		public String jenisKelamin {get;set;} 
		public String jabatanKerja {get;set;} 
		public String alamatKantorDepan {get;set;} 
		public String alamatKantorTengah {get;set;} 
		public String alamatKantorBelakang {get;set;} 
		public String alamatRumahDepan {get;set;} 
		public String alamatRumahBelakang {get;set;} 
		public String alamatEmail {get;set;} 
		public List<CardHolderData> cardHolderData {get;set;} 
		public List<AdditionalData> additionalData {get;set;} 
		public Portofolio portofolio {get;set;} 

		public CustomerData(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'namaDepan') {
							namaDepan = parser.getText();
						} else if (text == 'namaTengah') {
							namaTengah = parser.getText();
						} else if (text == 'namaBelakang') {
							namaBelakang = parser.getText();
						} else if (text == 'nomorHandphoneTerdaftar') {
							nomorHandphoneTerdaftar = parser.getText();
						} else if (text == 'nomorTelephoneKerabatTidakSerumah') {
							nomorTelephoneKerabatTidakSerumah = parser.getText();
						} else if (text == 'nomorTelephoneRumah') {
							nomorTelephoneRumah = parser.getText();
						} else if (text == 'nomorTelephoneKantor') {
							nomorTelephoneKantor = parser.getText();
						} else if (text == 'namaKerabatTidakSerumah') {
							namaKerabatTidakSerumah = parser.getText();
						} else if (text == 'nomorNik') {
							nomorNik = parser.getText();
						} else if (text == 'nomorNpwp') {
							nomorNpwp = parser.getText();
						} else if (text == 'sisaLimitNasabah') {
							sisaLimitNasabah = parser.getText();
						} else if (text == 'limitTarikTunaiNasabah') {
							limitTarikTunaiNasabah = parser.getText();
						} else if (text == 'sisaLimitTarikTunaiNasabah') {
							sisaLimitTarikTunaiNasabah = parser.getText();
						} else if (text == 'limitCicilanNasabah') {
							limitCicilanNasabah = parser.getText();
						} else if (text == 'sisaLimitCicilanNasabah') {
							sisaLimitCicilanNasabah = parser.getText();
						} else if (text == 'jenisKelamin') {
							jenisKelamin = parser.getText();
						} else if (text == 'jabatanKerja') {
							jabatanKerja = parser.getText();
						} else if (text == 'alamatKantorDepan') {
							alamatKantorDepan = parser.getText();
						} else if (text == 'alamatKantorTengah') {
							alamatKantorTengah = parser.getText();
						} else if (text == 'alamatKantorBelakang') {
							alamatKantorBelakang = parser.getText();
						} else if (text == 'alamatRumahDepan') {
							alamatRumahDepan = parser.getText();
						} else if (text == 'alamatRumahBelakang') {
							alamatRumahBelakang = parser.getText();
						} else if (text == 'alamatEmail') {
							alamatEmail = parser.getText();
						} else if (text == 'cardHolderData') {
							cardHolderData = arrayOfCardHolderData(parser);
						} else if (text == 'additionalData') {
							additionalData = arrayOfAdditionalData(parser);
						} else if (text == 'portofolio') {
							portofolio = new Portofolio(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'CustomerData consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Portofolio {
		public List<CreditCard> creditCard {get;set;} 
		public List<Investasi> investasi {get;set;} 
		public List<Loan> loan {get;set;} 
		public List<Loan> saving {get;set;} 

		public Portofolio(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'creditCard') {
							creditCard = arrayOfCreditCard(parser);
						} else if (text == 'investasi') {
							investasi = arrayOfInvestasi(parser);
						} else if (text == 'loan') {
							loan = arrayOfLoan(parser);
						} else if (text == 'saving') {
							saving = arrayOfLoan(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Portofolio consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Investasi {
		public String acctno {get;set;} 
		public Integer balance {get;set;} 
		public String cifno {get;set;} 
		public String product {get;set;} 
		public String productDescription {get;set;} 
		public String productType {get;set;} 
		public String status {get;set;} 

		public Investasi(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'acctno') {
							acctno = parser.getText();
						} else if (text == 'balance') {
							balance = parser.getIntegerValue();
						} else if (text == 'cifno') {
							cifno = parser.getText();
						} else if (text == 'product') {
							product = parser.getText();
						} else if (text == 'productDescription') {
							productDescription = parser.getText();
						} else if (text == 'productType') {
							productType = parser.getText();
						} else if (text == 'status') {
							status = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Investasi consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CreditCard {
		public String cardNumber {get;set;} 
		public String cifno {get;set;} 
		public String product {get;set;} 
		public String productDescription {get;set;} 
		public String productType {get;set;} 
		public String status {get;set;} 

		public CreditCard(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'cardNumber') {
							cardNumber = parser.getText();
						} else if (text == 'cifno') {
							cifno = parser.getText();
						} else if (text == 'product') {
							product = parser.getText();
						} else if (text == 'productDescription') {
							productDescription = parser.getText();
						} else if (text == 'productType') {
							productType = parser.getText();
						} else if (text == 'status') {
							status = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CreditCard consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static SCC_PhoneNumberWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new SCC_PhoneNumberWrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	

    private static List<CardHolderData> arrayOfCardHolderData(System.JSONParser p) {
        List<CardHolderData> res = new List<CardHolderData>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CardHolderData(p));
        }
        return res;
    }




    private static List<CreditCard> arrayOfCreditCard(System.JSONParser p) {
        List<CreditCard> res = new List<CreditCard>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CreditCard(p));
        }
        return res;
    }


    private static List<Investasi> arrayOfInvestasi(System.JSONParser p) {
        List<Investasi> res = new List<Investasi>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Investasi(p));
        }
        return res;
    }






    private static List<AdditionalData> arrayOfAdditionalData(System.JSONParser p) {
        List<AdditionalData> res = new List<AdditionalData>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AdditionalData(p));
        }
        return res;
    }




    private static List<Loan> arrayOfLoan(System.JSONParser p) {
        List<Loan> res = new List<Loan>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Loan(p));
        }
        return res;
    }




    private static List<CustomerData> arrayOfCustomerData(System.JSONParser p) {
        List<CustomerData> res = new List<CustomerData>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CustomerData(p));
        }
        return res;
    }


}