clear; clc;

zip_path = "stanford_processed_mat_only.zip";
out_dir = "mat_data";

if ~isfolder(out_dir)
    unzip(zip_path, out_dir);
end

labels = readtable("stanford_soh_labels.csv");
labels.cell_id = string(labels.cell_id);

mat_files = dir(fullfile(out_dir, "**", "*.mat"));

fprintf("mat files: %d\n", length(mat_files));
disp(fullfile(mat_files(1).folder, mat_files(1).name));

sample_path = fullfile(mat_files(1).folder, mat_files(1).name);
S = load(sample_path);
disp(fieldnames(S));
head(S.data_final)

seq_len = 300;

X_list = {};
y_list = [];
meta_cell = {};

for i = 1:length(mat_files)
    mat_path = fullfile(mat_files(i).folder, mat_files(i).name);

    cycling_id = parse_cycling_id_local(mat_path);
    cell_id = erase(string(mat_files(i).name), ".mat");
    rpt_id = cycling_id + 1;

    if isnan(cycling_id)
        continue
    end

    label_idx = labels.cell_id == cell_id & labels.rpt_id == rpt_id;

    if ~any(label_idx)
        continue
    end

    S = load(mat_path);

    if ~isfield(S, "data_final")
        continue
    end

    seq = extract_charge_sequence_local(S.data_final, seq_len);

    if isempty(seq)
        continue
    end

    X_list{end+1, 1} = seq;
    y_list(end+1, 1) = labels.soh(find(label_idx, 1));

    meta_cell(end+1, :) = {
        cell_id, cycling_id, rpt_id, string(mat_path)
    };
end

X = cat(3, X_list{:});
X = permute(X, [3 1 2]);  % samples x time x channels
y = y_list;

meta = cell2table(meta_cell, ...
    "VariableNames", ["cell_id", "cycling_id", "rpt_id", "file"]);

save("stanford_timeseries_dataset.mat", "X", "y", "meta", "-v7.3");
writetable(meta, "stanford_timeseries_meta.csv");

fprintf("X size:\n");
disp(size(X));

fprintf("y size:\n");
disp(size(y));

head(meta)

function cycling_id = parse_cycling_id_local(path_text)
    token = regexp(string(path_text), "Cycling_(\d+)", "tokens", "once");
    if isempty(token)
        cycling_id = NaN;
    else
        cycling_id = str2double(token{1});
    end
end

function seq = extract_charge_sequence_local(T, seq_len)
    vars = string(T.Properties.VariableNames);
    lower_vars = lower(vars);

    time_col = vars(contains(lower_vars, "test_time"));
    voltage_col = vars(contains(lower_vars, "voltage"));
    current_col = vars(contains(lower_vars, "current"));
    temp_col = vars(contains(lower_vars, "temp"));
    dvdt_col = vars(contains(lower_vars, "dv") & contains(lower_vars, "dt"));

    if isempty(time_col) || isempty(voltage_col) || isempty(current_col)
        seq = [];
        return
    end

    time = T.(time_col(1));
    voltage = T.(voltage_col(1));
    current = T.(current_col(1));

    if ~isempty(temp_col)
        temperature = T.(temp_col(1));
    else
        temperature = nan(height(T), 1);
    end

    if ~isempty(dvdt_col)
        dvdt = T.(dvdt_col(1));
    else
        dvdt = nan(height(T), 1);
    end

    [~, order] = sort(time);
    voltage = voltage(order);
    current = current(order);
    temperature = temperature(order);
    dvdt = dvdt(order);

    charge_idx = current > 0.05;

    if sum(charge_idx) < 30
        seq = [];
        return
    end

    data = [voltage, current, temperature, dvdt];
    data = data(charge_idx, :);

    if size(data, 1) >= seq_len
        seq = data(end-seq_len+1:end, :);
    else
        pad = repmat(data(1, :), seq_len - size(data, 1), 1);
        seq = [pad; data];
    end
end