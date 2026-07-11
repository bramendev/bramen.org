import sys
try:
    from PyPDF2 import PdfReader
except ImportError:
    print("PyPDF2 not installed, trying pdfplumber...")
    try:
        import pdfplumber
        pdf = pdfplumber.open('/home/bramen/bramen.org/resume.pdf')
        text = ''
        for page in pdf.pages:
            text += page.extract_text() + '\n'
        print(text)
        pdf.close()
        sys.exit(0)
    except ImportError:
        print("pdfplumber not installed, trying pypdf...")
        try:
            from pypdf import PdfReader
        except ImportError:
            print("No PDF library available")
            sys.exit(1)

reader = PdfReader('/home/bramen/bramen.org/resume.pdf')
text = ''
for page in reader.pages:
    text += page.extract_text() + '\n'
print(text)
