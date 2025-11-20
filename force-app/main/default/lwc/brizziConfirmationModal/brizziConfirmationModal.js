import { LightningElement, api } from 'lwc';

export default class ConfirmationModal extends LightningElement {
    @api oldCardNumber;
    @api newCardNumber;
    @api saldoKartu;
    @api saldoDeposit;

    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleConfirm() {
        this.dispatchEvent(new CustomEvent('confirm'));
    }
}