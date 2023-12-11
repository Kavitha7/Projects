import streamlit as st
import numpy as np
import pickle
import re
import random
import socket
from urllib.parse import urlparse
model = pickle.load(open('rf_pred', 'rb'))
st.title("Phishing Detector")
st.subheader("Phishing Domain Detector Engine")
with st.form("form1", clear_on_submit=False):
    text_input = st.text_input("Enter a URL")

    if st.form_submit_button("Go"):
        domain = urlparse(text_input).netloc

        text = "AaEeIiOoUu"
        count = [i for i in str(domain) if i in text]
        vowels = len(count)

        length = len(domain)

        address = socket.gethostbyname(domain)
        ip = None
        if address != None:
            ip = 1
        else:
            ip = 0

        lis= [0,1]
        server = random.choice(lis)

        sign = re.findall("[._/?=@&! ,+*#$%]", domain)
        sign_count = len(sign)

        features = []
        final_features = features.append(str(text_input))
        final_features = np.array(final_features)
        final_features1 = final_features.reshape(-1,1)
        final_features1.reset()
        prediction = ''.join(model.predict(final_features1))
        output = prediction[0]


        if output == 0:
            st.markdown('The Domain is Legitimate')
        else:
            st.markdown('The Domain is Malicious')
