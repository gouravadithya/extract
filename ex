import pytesseract
from pdf2image import convert_from_path
import spacy
nlp = spacy.load("en_core_web_md")
def ocr_pdf(file_path):
    images = convert_from_path(file_path)
    text = ""
    for image in images:
        text += pytesseract.image_to_string(image)
    print(text)
def extract_information(text, page_number):
    global nlp
    doc = nlp(text.upper())
    print(doc)
    invoice_number_patterns = [
        r'(TAX|Invoice)\s*(INVOICE|Number|ID|No|#)\s*[:\n]\s*([^\n]+)',
        r'(TAX|INVOICE)#\s*[:\n]\s*([^\n]+)',
        r'(tax|invoice)#\s*[:\n]\s*([^\n]+)',
        r'(TAx)'
    ]
    due_date_patterns = [
        r'Due\s*Date\s*:\s*([^\n]+)',
        r'Dated\s\s*:\s*([^\n]+)',
        r'(\d{1,2}[-./]\d{1,2}[-./]\d{2,4})',  
        r'|\b(\d{4}[-./]\d{1,2}[-./]\d{1,2})\b',  
        r'|\b([A-Za-z]+ \d{1,2},? \d{2,4})\b',  
        r'|\b(\d{1,2} [A-Za-z]+ \d{2,4})\b',  
        r'|\b(\d{1,2}[-./]\d{1,2}[-./]\d{2})\b',  
        r'|\b([A-Za-z]+ \d{1,2}[,]? \d{2,4})\b',  
        r'|\b(\d{1,2} [A-Za-z]+[,]? \d{2,4})\b'  
    ]
    biller_patterns = [
        r'Biller/Seller\s*Information\s*:\s*([^\n]+)\s*',
        r'Seller\s*Information\s*:\s*([^\n]+)\s*',
        r'Billing\s*From\s*:\s*([^\n]+)\s*',
        r'Company\s*Name\s*:\s*([^\n]+)\s*'
    ]
    buyer_patterns = [
        r'Customer/Buyer\s*Information\s*:\s*([^\n]+)\s*',
        r'Buyer\s*Information\s*:\s*([^\n]+)\s*',        
    ]
    tax_patterns = [
        r'Tax\s*Information\s*:\s*([^\n]+)\s*',
        r'Breakdown\s*of\s*Taxes\s*:\s*([^\n]+)\s*'
    ]
    payment_terms_patterns = [
        r'Payment\s*Terms\s*:\*([^\n]+)\s*',
        r'Terms\s*of\s*Payment\s*:\s*([^\n]+)\s*'
    ]
    po_number_patterns = [
        r'Purchase\s*Order\s*(PO)?\s*Number\s*:\s*([^\n]+)\s*',
        r'PO\s*Number\s*:\s*([^\n]+)\s*'
    ]
    products_patterns = [
        r'Description\s*of\s*Products/Services\s*:\s*([^\n]+)\s*',
        r'Products/Services\s*Description\s*:\s*([^\n]+)\s*'
    ]
    total_amount_patterns = [
        r'Total\s*Amount\s*Due[^:]*:\s*([^\n]+)',
        r'Total*([^\n]+)',
        r'Total[^:]*:\s*([^\n]+)'
        r'Total\s*Due\s*:\s*([^\n]+)\s*'
]    
    terms_patterns = [
        r'Terms\s*and\s*Conditions\s*:\s*([^\n]+)\s*',
        r'Conditions\s*of\s*Sale\s*:\s*([^\n]+)\s*'
    ]
    invoice_info = {
        'Invoice Number': [],
        'Due Date': [],
        'Biller/Seller Information': [],
        'Buyer/Customer Information': [],
        'Description of Products/Services': [],
        'Total Amount Due': [],
        'Tax Information': [],
        'Payment Terms': [],
        'Purchase Order Number': [],
        'Terms and Conditions': []
    }
    for ent in doc.ents:
        if ent.label_ in invoice_info:
            invoice_info[ent.label_].append(ent.text)
    return {f'{key} - Page {page_number}': value for key, value in invoice_info.items() if value}
def process_multi_page_invoice(pdf_file_path):
    images = convert_from_path(pdf_file_path)
    results = []
    for i, image in enumerate(images, start=1):
        page_text = pytesseract.image_to_string(image)
        print(f"Processing Page {i}")
        result = extract_information(page_text, i)
        results.append(result)
    return results
pdf_file_path = "hi.pdf"
results = process_multi_page_invoice(pdf_file_path)
for i, result in enumerate(results, start=1):
    print(f"\nDetails for Page {i}:")
    print(result)
