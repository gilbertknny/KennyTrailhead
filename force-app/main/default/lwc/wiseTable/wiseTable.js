import { LightningElement, track } from 'lwc';

export default class DataTable extends LightningElement {
    @track processedData = [];

    connectedCallback() {
        // Simulasi data response
        const data = {
            name: "Parameter Biaya Kartu Kredit Samsung Card",
            table_data: [
                [
                    {
                        "key": "0-0",
                        "value": "PARAMETER/BIAYA",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "0-1",
                        "value": "SAMSUNG PLATINUM",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "0-2",
                        "value": "SAMSUNG SIGNATURE",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "1-0",
                        "value": "Bunga Transaksi Ritel ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "1-1",
                        "value": "1,75% / bulan ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "1-2",
                        "value": "1,75% / bulan",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "2-0",
                        "value": "Bunga Tarik Tunai ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "2-1",
                        "value": "1,75% / bulan ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "2-2",
                        "value": "1,75% / bulan",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "3-0",
                        "value": "Annual Fee ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "3-1",
                        "value": "Rp300.000",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "3-2",
                        "value": "Rp600.000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "4-0",
                        "value": "Biaya Overlimit ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "4-1",
                        "value": "Rp100.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "4-2",
                        "value": "Rp200.000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "5-0",
                        "value": "Biaya Keterlambatan Pembayaran ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "5-1",
                        "value": "1% dari total tagihan atau maks. 100.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "5-2",
                        "value": "1% dari total tagihan atau maks. 100.000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "6-0",
                        "value": "Biaya Penggantian Kartu ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "6-1",
                        "value": "Rp75.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "6-2",
                        "value": "Rp100.000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "7-0",
                        "value": "Biaya Pengiriman Tagihan Kertas",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "7-1",
                        "value": "Rp20.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "7-2",
                        "value": "Rp20.000 ",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "8-0",
                        "value": "Biaya Cetak Ulang Billing ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "8-1",
                        "value": "Rp10.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "8-2",
                        "value": "Rp10.000 ",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "9-0",
                        "value": "Biaya Copy Sales Draft Lokal ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "9-1",
                        "value": "Rp25.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "9-2",
                        "value": "Rp25.000 ",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "10-0",
                        "value": "Biaya Copy Sales Draft Internasional ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "10-1",
                        "value": "Rp150.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "10-2",
                        "value": "Rp150.000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "11-0",
                        "value": "Biaya Penggantian PIN ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "11-1",
                        "value": "Rp25.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "11-2",
                        "value": "Rp25.000 ",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "12-0",
                        "value": "Biaya Ringkasan Transaksi Tahunan ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "12-1",
                        "value": "Rp100,000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "12-2",
                        "value": "Rp100,000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "13-0",
                        "value": "Biaya Kenaikan Limit ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "13-1",
                        "value": "Rp50.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "13-2",
                        "value": "Rp100.000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "14-0",
                        "value": "Biaya Penagihan ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "14-1",
                        "value": "Rp50.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "14-2",
                        "value": "Rp50.000 ",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "15-0",
                        "value": "Biaya Admin Tarik Tunai ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "15-1",
                        "value": "6% atau min. 100.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "15-2",
                        "value": "6% atau min. 100.000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "16-0",
                        "value": "Biaya Materai untuk tagihan \u003e Rp 5 juta ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "16-1",
                        "value": "Rp10.000",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "16-2",
                        "value": "Rp10.000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "17-0",
                        "value": "Biaya Notifikasi",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "17-1",
                        "value": "Rp7.500 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "17-2",
                        "value": "Rp7.500 ",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "18-0",
                        "value": "Biaya Pengiriman E-Statement ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "18-1",
                        "value": "Rp5.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "18-2",
                        "value": "Rp5.000 ",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "19-0",
                        "value": "Biaya Refund Saldo Kredit ke Rekening BRI",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "19-1",
                        "value": "Rp25.000",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "19-2",
                        "value": "Rp25.000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "20-0",
                        "value": "Min. Pembayaran",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "20-1",
                        "value": " 5% dari tagihan atau minimum 50.000 ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "20-2",
                        "value": "5% dari tagihan atau minimum 50.000",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "21-0",
                        "value": "Maks. Tarik Tunai ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "21-1",
                        "value": "60% dari sisa limit atau 10.000.000 per hari",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "21-2",
                        "value": "60% dari sisa limit atau 10.000.000 per hari",
                        "row_span": 1,
                        "col_span": 1
                    }
                ],
                [
                    {
                        "key": "22-0",
                        "value": "Jatuh tempo ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "22-1",
                        "value": "17 hari sejak tanggal cetak tagihan ",
                        "row_span": 1,
                        "col_span": 1
                    },
                    {
                        "key": "22-2",
                        "value": "17 hari sejak tanggal cetak tagihan ",
                        "row_span": 1,
                        "col_span": 1
                    }
                ]
            ]
        };

        this.processData(data);
    }

    processData(response) {
        if (response && response.table_data) {
            this.processedData = response.table_data.map((row, index) => {
                return row.map(cell => ({
                    ...cell,
                    id: `row-${index}`
                }));
            });
        }
    }
}