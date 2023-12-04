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
    features = []
    final_features = features.append(str(text_input))
    prediction = ''.join(model.predict(final_features))
    output = prediction[0]
if output == 0:
    st.markdown('The Domin is Legitimate')
else:
    st.markdown('The Domin is Malicious')
