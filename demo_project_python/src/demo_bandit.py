import subprocess
import pickle
import yaml

def run_user_cmd(user_input: str) -> str:
    # Bandit sẽ cảnh báo: shell=True với input user
    # out = subprocess.check_output(f"echo {user_input}", shell=True, text=True)
    # return out
    pass

def unsafe_deserialize(blob: bytes):
    # Bandit sẽ cảnh báo: pickle loads
    # return pickle.loads(blob)
    pass

def unsafe_yaml_load(yaml_text: str):
    # Bandit sẽ cảnh báo: yaml.load không dùng safe_load
    # return yaml.load(yaml_text, Loader=yaml.FullLoader)
    pass
