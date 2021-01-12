#!/usr/bin/env bash
###############################################################################
# PURPOSE:
# Uses Sphinx with autodoc and chalicedoc plugins to generate pretty HTML
# documentation from docstrings in source/dataplaneapi/api.py and
# source/workflowapi/api.py. Output docs will be saved to doc/sphinx/output/.
#
# This output is manually copied to the MIE wiki:
#   https://w.amazon.com/bin/view/Media_insights_engine/docs
#
# PRELIMINARY:
#  python3 must be installed.
#
# USAGE:
#  cd doc/sphinx/
#  ./build_docs.sh
#  open output/index.html
#
###############################################################################

# Create and activate a temporary Python environment for this script.
echo "------------------------------------------------------------------------------"
echo "Creating a temporary Python virtualenv for this script"
echo "------------------------------------------------------------------------------"
source_dir="../../source"
docs_dir=`pwd`

python -c "import os; print (os.getenv('VIRTUAL_ENV'))" | grep -q None
if [ $? -ne 0 ]; then
    echo "ERROR: Do not run this script inside Virtualenv. Type \`deactivate\` and run again.";
    exit 1;
fi
which python3
if [ $? -ne 0 ]; then
    echo "ERROR: install Python3 before running this script"
    exit 1
fi
VENV=$(mktemp -d)
python3 -m venv $VENV
source $VENV/bin/activate
pip install sphinx boto3 chalice chalicedoc autodoc jsonschema aws_xray_sdk

cd "$source_dir"/lib/MediaInsightsEngineLambdaHelper || exit 1
rm -rf build
rm -rf dist
rm -rf Media_Insights_Engine_Lambda_Helper.egg-info
python3 setup.py bdist_wheel > /dev/null
pip install dist/Media_Insights_Engine_Lambda_Helper-0.0.4-py3-none-any.whl


if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install required Python libraries."
    exit 1
fi

export WORKFLOW_SCHEDULER_LAMBDA_ARN="test"
export OPERATOR_FAILED_LAMBDA_ARN="test"
export FILTER_OPERATION_LAMBDA_ARN="test"
export SYSTEM_TABLE_NAME="test"
export WORKFLOW_TABLE_NAME="test"
export STAGE_TABLE_NAME="test"
export OPERATION_TABLE_NAME="test"
export WORKFLOW_EXECUTION_TABLE_NAME="test"
export STAGE_EXECUTION_QUEUE_URL="test"
export STAGE_EXECUTION_ROLE="test"
export COMPLETE_STAGE_LAMBDA_ARN="test"
export DATAPLANE_TABLE_NAME="test"
export DATAPLANE_BUCKET="test"
export STACK_SHORT_UUID="test"
export HISTORY_TABLE_NAME="test"

cd "$docs_dir"

sphinx-build -b html . ../
