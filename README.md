# Second-Life Battery SOH Preprocessing

Stanford second-life battery dataset을 이용해 충전 데이터 기반 SOH 예측 및 불확실성 정량화 실험을 준비하기 위한 전처리 코드입니다.

현재 repository에는 전처리 코드만 포함되어 있으며, 원본 데이터와 생성된 대용량 processed data는 포함하지 않습니다.

## 연구 목적

본 프로젝트의 최종 목표는 사용후 리튬이온 배터리의 충전 데이터로 SOH를 예측하고, 예측 불확실성을 정량화하여 재사용 적합성 판단에 활용하는 것입니다.

현재 단계에서는 다음 데이터를 생성합니다.

- RPT capacity 기반 SOH label
- 충전 데이터 기반 tabular feature
- `.mat` 기반 charging time-series dataset

## 폴더 구조

```text
Gradaution-rookies/
├─ README.md
├─ requirements.txt
├─ notebooks/
│  ├─ 01_dataset_check.ipynb
│  ├─ 02_make_soh_labels.ipynb
│  ├─ 03_make_tabular_features.ipynb
│  └─ 04_load_timeseries_dataset.ipynb
└─ matlab/
   └─ make_timeseries_dataset.m
```

## 파일별 역할

```text
01_dataset_check.ipynb
→ 원본 데이터 구조 확인

02_make_soh_labels.ipynb
→ RPT 기반 SOH label 생성

03_make_tabular_features.ipynb
→ xlsx 기반 tabular feature 생성

make_timeseries_dataset.m
→ mat 기반 time-series dataset 생성

04_load_timeseries_dataset.ipynb
→ 생성된 time-series dataset 확인 및 Colab 로딩
```

## 생성되는 데이터 파일

아래 파일들은 모델링 단계에서 사용합니다.  
단, 대용량 데이터 파일은 GitHub에 포함하지 않고 별도 Google Drive로 공유합니다.

```text
stanford_soh_labels.csv
stanford_post_charge_features_only.csv
stanford_post_charge_features.csv
stanford_timeseries_dataset.mat
stanford_timeseries_meta.csv
```

## 생성 파일 설명

```text
stanford_soh_labels.csv
→ RPT capacity test에서 생성한 SOH label

stanford_post_charge_features_only.csv
→ cycling xlsx에서 추출한 tabular feature

stanford_post_charge_features.csv
→ tabular feature와 SOH label을 결합한 학습용 데이터

stanford_timeseries_dataset.mat
→ .mat 파일에서 생성한 charging time-series 학습용 데이터

stanford_timeseries_meta.csv
→ time-series 샘플의 cell_id, cycling_id, rpt_id, file 정보
```

## 데이터 사용 방식

Tabular 모델링에는 아래 파일을 사용합니다.

```text
stanford_post_charge_features.csv
```

Time-series 모델링에는 아래 두 파일을 사용합니다.

```text
stanford_timeseries_dataset.mat
stanford_timeseries_meta.csv
```

