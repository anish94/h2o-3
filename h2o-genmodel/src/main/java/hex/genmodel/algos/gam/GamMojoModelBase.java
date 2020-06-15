package hex.genmodel.algos.gam;

import hex.genmodel.MojoModel;

public abstract class GamMojoModelBase extends MojoModel {
    boolean _useAllFactorLevels;
    
    int _cats;
    int[] _catNAFills;
    int[] _catOffsets;
    
    int _nums;
    int[] _numNAFills;
    boolean _meanImputation;
    
    double[] _beta;
    String _family;
    
    GamMojoModelBase(String[] columns, String[][] domains, String responseColumn) {
        super(columns, domains, responseColumn);
    }

    void init() { /* do nothing by default */ }
    
    @Override
    public final double[] score0(double[] data, double[] preds) {
        if (_meanImputation)
            imputeMissingWithMeans(data);

        return gamScore0(data, preds);
    }

    abstract double[] gamScore0(double[] data, double[] preds);
    
    private void imputeMissingWithMeans(double[] data) {
        for (int i=0; i < _cats; i++) {
            if (Double.isNaN(data[i])) data[i] = _catNAFills[i];
        }
        for (int i=0; i < _nums; i++) {
            if (Double.isNaN(data[i])) data[i] = _numNAFills[i];
        }
    }
}
