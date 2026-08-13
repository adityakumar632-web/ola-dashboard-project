"""
Ola Ride Booking Data Analytics — Streamlit Dashboard
------------------------------------------------------
Run with:  streamlit run app.py

Expects ola_bookings_cleaned.csv in the same folder (falls back to a
file-uploader if it isn't found), so this can drop straight into the
project folder from the Excel/SQL stage.
"""

import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st
from pathlib import Path

# ------------------------------------------------------------------
# PAGE CONFIG
# ------------------------------------------------------------------
st.set_page_config(
    page_title="Ola Ride Booking Analytics",
    page_icon="🚕",
    layout="wide",
    initial_sidebar_state="expanded",
)

PRIMARY = "#0B5ED7"
ACCENT = "#00C2A8"
DANGER = "#E5484D"
GREY = "#6B7280"

st.markdown(
    f"""
    <style>
        .stMetric {{
            background-color: #F8F9FB;
            border: 1px solid #E5E7EB;
            border-radius: 10px;
            padding: 14px 10px 6px 10px;
        }}
        div[data-testid="stMetricValue"] {{
            color: {PRIMARY};
            font-weight: 700;
        }}
        .block-container {{ padding-top: 1.4rem; }}
        h1, h2, h3 {{ color: #1F2937; }}
    </style>
    """,
    unsafe_allow_html=True,
)

# ------------------------------------------------------------------
# DATA LOADING
# ------------------------------------------------------------------
DEFAULT_PATH = Path(__file__).parent / "ola_bookings_cleaned.csv"


@st.cache_data
def load_data(file) -> pd.DataFrame:
    df = pd.read_csv(file)
    df["Booking Date"] = pd.to_datetime(df["Booking Date"])
    numeric_cols = [
        "Ride Distance (km)", "Booking Value (INR)", "Driver Rating",
        "Customer Rating", "Ride Duration (min)", "Revenue per KM", "Booking Hour",
    ]
    for c in numeric_cols:
        if c in df.columns:
            df[c] = pd.to_numeric(df[c], errors="coerce")
    return df


if DEFAULT_PATH.exists():
    df_raw = load_data(DEFAULT_PATH)
else:
    st.sidebar.warning("ola_bookings_cleaned.csv not found next to app.py — upload it below.")
    uploaded = st.sidebar.file_uploader("Upload cleaned Ola dataset (CSV)", type="csv")
    if uploaded is None:
        st.title("🚕 Ola Ride Booking Analytics")
        st.info("Upload the cleaned dataset in the sidebar to load the dashboard.")
        st.stop()
    df_raw = load_data(uploaded)

# ------------------------------------------------------------------
# SIDEBAR — SLICERS
# ------------------------------------------------------------------
st.sidebar.title("🚕 Ola Analytics")
st.sidebar.caption("Filter the dashboard — mirrors the Power BI slicer panel.")

min_date, max_date = df_raw["Booking Date"].min(), df_raw["Booking Date"].max()
date_range = st.sidebar.date_input(
    "Booking Date",
    value=(min_date.date(), max_date.date()),
    min_value=min_date.date(),
    max_value=max_date.date(),
)
if isinstance(date_range, tuple) and len(date_range) == 2:
    start_date, end_date = date_range
else:
    start_date, end_date = min_date.date(), max_date.date()

vehicle_opts = sorted(df_raw["Vehicle Type"].dropna().unique())
vehicle_sel = st.sidebar.multiselect("Vehicle Type", vehicle_opts, default=vehicle_opts)

status_opts = sorted(df_raw["Booking Status"].dropna().unique())
status_sel = st.sidebar.multiselect("Booking Status", status_opts, default=status_opts)

payment_opts = sorted(df_raw["Payment Method"].dropna().unique())
payment_sel = st.sidebar.multiselect("Payment Method", payment_opts, default=payment_opts)

pickup_opts = sorted(df_raw["Pickup Location"].dropna().unique())
pickup_sel = st.sidebar.multiselect("Pickup Location", pickup_opts, default=pickup_opts)

if st.sidebar.button("Reset filters"):
    st.rerun()

# ------------------------------------------------------------------
# APPLY FILTERS
# ------------------------------------------------------------------
mask = (
    (df_raw["Booking Date"].dt.date >= start_date)
    & (df_raw["Booking Date"].dt.date <= end_date)
    & (df_raw["Vehicle Type"].isin(vehicle_sel))
    & (df_raw["Booking Status"].isin(status_sel))
    & (df_raw["Payment Method"].isin(payment_sel))
    & (df_raw["Pickup Location"].isin(pickup_sel))
)
df = df_raw.loc[mask].copy()
success = df[df["Booking Status"] == "Success"]

if df.empty:
    st.title("🚕 Ola Ride Booking Analytics")
    st.warning("No bookings match the current filters. Adjust the sidebar selections.")
    st.stop()

# ------------------------------------------------------------------
# HEADER + KPI ROW
# ------------------------------------------------------------------
st.title("🚕 Ola Ride Booking Analytics")
st.caption(
    f"{len(df):,} bookings between {start_date} and {end_date} "
    f"— {len(df):,} of {len(df_raw):,} total records match the current filters"
)

total_bookings = len(df)
successful = len(success)
cancelled = int((df["Is Cancelled"] == "Yes").sum())
cancel_rate = cancelled / total_bookings if total_bookings else 0
total_revenue = success["Booking Value (INR)"].sum()
avg_booking_value = success["Booking Value (INR)"].mean() if not success.empty else 0
avg_distance = df["Ride Distance (km)"].mean()
avg_duration = success["Ride Duration (min)"].mean() if not success.empty else 0

k1, k2, k3, k4 = st.columns(4)
k1.metric("Total Bookings", f"{total_bookings:,}")
k2.metric("Successful Rides", f"{successful:,}", f"{successful/total_bookings:.1%} success rate")
k3.metric("Cancelled Rides", f"{cancelled:,}", f"{cancel_rate:.1%} cancellation rate", delta_color="inverse")
k4.metric("Total Revenue", f"₹{total_revenue:,.0f}")

k5, k6, k7, k8 = st.columns(4)
k5.metric("Avg Booking Value", f"₹{avg_booking_value:,.1f}")
k6.metric("Avg Ride Distance", f"{avg_distance:,.1f} km")
k7.metric("Avg Ride Duration", f"{avg_duration:,.1f} min")
k8.metric(
    "Avg Driver / Customer Rating",
    f"{success['Driver Rating'].mean():.2f} / {success['Customer Rating'].mean():.2f}",
)

st.divider()

# ------------------------------------------------------------------
# TABS — mirrors the 3 Power BI report pages
# ------------------------------------------------------------------
tab1, tab2, tab3 = st.tabs(["📈 Executive Overview", "📍 Cancellations & Locations", "⭐ Ratings & Customers"])

# ---------------- TAB 1: EXECUTIVE OVERVIEW ----------------
with tab1:
    c1, c2 = st.columns((2, 1))

    with c1:
        st.subheader("Booking Trend by Date")
        trend = (
            df.groupby(df["Booking Date"].dt.date)
            .agg(Total_Bookings=("Booking ID", "count"),
                 Revenue=("Booking Value (INR)", lambda s: s[df.loc[s.index, "Booking Status"] == "Success"].sum()))
            .reset_index()
            .rename(columns={"Booking Date": "Date"})
        )
        fig = go.Figure()
        fig.add_trace(go.Scatter(x=trend["Date"], y=trend["Total_Bookings"], name="Total Bookings",
                                  mode="lines", line=dict(color=PRIMARY, width=2)))
        fig.add_trace(go.Bar(x=trend["Date"], y=trend["Revenue"], name="Revenue (INR)",
                              marker_color=ACCENT, opacity=0.35, yaxis="y2"))
        fig.update_layout(
            yaxis=dict(title="Bookings"),
            yaxis2=dict(title="Revenue (INR)", overlaying="y", side="right", showgrid=False),
            legend=dict(orientation="h", y=1.12),
            margin=dict(t=10, b=10), height=360,
        )
        st.plotly_chart(fig, use_container_width=True)

    with c2:
        st.subheader("Booking Status")
        status_counts = df["Booking Status"].value_counts().reset_index()
        status_counts.columns = ["Status", "Count"]
        fig = px.pie(status_counts, names="Status", values="Count", hole=0.55,
                     color_discrete_sequence=px.colors.qualitative.Set2)
        fig.update_layout(margin=dict(t=10, b=10), height=360, showlegend=True)
        st.plotly_chart(fig, use_container_width=True)

    c3, c4 = st.columns(2)
    with c3:
        st.subheader("Revenue by Vehicle Type")
        rev_vehicle = (success.groupby("Vehicle Type")["Booking Value (INR)"]
                        .sum().sort_values(ascending=False).reset_index())
        fig = px.bar(rev_vehicle, x="Vehicle Type", y="Booking Value (INR)",
                     color_discrete_sequence=[PRIMARY], text_auto=".2s")
        fig.update_layout(margin=dict(t=10, b=10), height=340, yaxis_title="Revenue (INR)")
        st.plotly_chart(fig, use_container_width=True)

    with c4:
        st.subheader("Payment Method Distribution")
        pay = success["Payment Method"].value_counts().reset_index()
        pay.columns = ["Payment Method", "Rides"]
        fig = px.bar(pay.sort_values("Rides"), x="Rides", y="Payment Method", orientation="h",
                     color_discrete_sequence=[ACCENT], text_auto=True)
        fig.update_layout(margin=dict(t=10, b=10), height=340)
        st.plotly_chart(fig, use_container_width=True)

# ---------------- TAB 2: CANCELLATIONS & LOCATIONS ----------------
with tab2:
    c1, c2 = st.columns(2)
    with c1:
        st.subheader("Cancellation Reason Analysis")
        cancelled_df = df[df["Is Cancelled"] == "Yes"]
        if cancelled_df.empty:
            st.info("No cancelled bookings in the current filter selection.")
        else:
            reasons = (cancelled_df["Cancellation Reason"].value_counts()
                       .reset_index())
            reasons.columns = ["Reason", "Count"]
            fig = px.bar(reasons.sort_values("Count"), x="Count", y="Reason", orientation="h",
                         color_discrete_sequence=[DANGER], text_auto=True)
            fig.update_layout(margin=dict(t=10, b=10), height=380)
            st.plotly_chart(fig, use_container_width=True)

    with c2:
        st.subheader("Cancellation Rate by Vehicle Type")
        cr = (df.groupby("Vehicle Type")["Is Cancelled"]
              .apply(lambda s: (s == "Yes").mean())
              .sort_values(ascending=False).reset_index())
        cr.columns = ["Vehicle Type", "Cancellation Rate"]
        fig = px.bar(cr, x="Vehicle Type", y="Cancellation Rate", color_discrete_sequence=[DANGER])
        fig.update_layout(margin=dict(t=10, b=10), height=380, yaxis_tickformat=".0%")
        st.plotly_chart(fig, use_container_width=True)

    c3, c4 = st.columns(2)
    with c3:
        st.subheader("Top 10 Pickup Locations")
        top_pickup = df["Pickup Location"].value_counts().head(10).sort_values().reset_index()
        top_pickup.columns = ["Location", "Bookings"]
        fig = px.bar(top_pickup, x="Bookings", y="Location", orientation="h",
                     color_discrete_sequence=[PRIMARY], text_auto=True)
        fig.update_layout(margin=dict(t=10, b=10), height=380)
        st.plotly_chart(fig, use_container_width=True)

    with c4:
        st.subheader("Top 10 Drop Locations")
        top_drop = df["Drop Location"].value_counts().head(10).sort_values().reset_index()
        top_drop.columns = ["Location", "Bookings"]
        fig = px.bar(top_drop, x="Bookings", y="Location", orientation="h",
                     color_discrete_sequence=[ACCENT], text_auto=True)
        fig.update_layout(margin=dict(t=10, b=10), height=380)
        st.plotly_chart(fig, use_container_width=True)

    st.subheader("Demand Heatmap — Day of Week × Hour of Day")
    day_order = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    heat = (df.groupby(["Booking Day", "Booking Hour"]).size()
            .reset_index(name="Bookings"))
    heat_pivot = heat.pivot(index="Booking Day", columns="Booking Hour", values="Bookings").reindex(day_order)
    fig = px.imshow(heat_pivot, aspect="auto", color_continuous_scale="Blues",
                     labels=dict(x="Hour of Day", y="Day of Week", color="Bookings"))
    fig.update_layout(margin=dict(t=10, b=10), height=340)
    st.plotly_chart(fig, use_container_width=True)

# ---------------- TAB 3: RATINGS & CUSTOMERS ----------------
with tab3:
    c1, c2 = st.columns(2)
    with c1:
        st.subheader("Driver Rating Distribution")
        fig = px.histogram(success.dropna(subset=["Driver Rating"]), x="Driver Rating", nbins=20,
                            color_discrete_sequence=[PRIMARY])
        fig.update_layout(margin=dict(t=10, b=10), height=340)
        st.plotly_chart(fig, use_container_width=True)

    with c2:
        st.subheader("Customer Rating Distribution")
        fig = px.histogram(success.dropna(subset=["Customer Rating"]), x="Customer Rating", nbins=20,
                            color_discrete_sequence=[ACCENT])
        fig.update_layout(margin=dict(t=10, b=10), height=340)
        st.plotly_chart(fig, use_container_width=True)

    c3, c4 = st.columns(2)
    with c3:
        st.subheader("Average Rating by Vehicle Type")
        rate_vehicle = (success.groupby("Vehicle Type")[["Driver Rating", "Customer Rating"]]
                         .mean().reset_index())
        fig = px.bar(rate_vehicle, x="Vehicle Type", y=["Driver Rating", "Customer Rating"],
                     barmode="group", color_discrete_sequence=[PRIMARY, ACCENT])
        fig.update_layout(margin=dict(t=10, b=10), height=340, yaxis_title="Avg Rating", legend_title="")
        st.plotly_chart(fig, use_container_width=True)

    with c4:
        st.subheader("Repeat vs One-Time Customers")
        cust_counts = df.groupby("Customer ID").size()
        rep = pd.Series({
            "Repeat customer": (cust_counts > 1).sum(),
            "One-time customer": (cust_counts == 1).sum(),
        }).reset_index()
        rep.columns = ["Type", "Customers"]
        fig = px.pie(rep, names="Type", values="Customers", hole=0.55,
                     color_discrete_sequence=[PRIMARY, "#CBD5E1"])
        fig.update_layout(margin=dict(t=10, b=10), height=340)
        st.plotly_chart(fig, use_container_width=True)

st.divider()

# ------------------------------------------------------------------
# RAW DATA EXPANDER
# ------------------------------------------------------------------
with st.expander("📄 View filtered data table"):
    st.dataframe(df, use_container_width=True, height=400)
    st.download_button(
        "Download filtered data as CSV",
        data=df.to_csv(index=False).encode("utf-8"),
        file_name="ola_bookings_filtered.csv",
        mime="text/csv",
    )
