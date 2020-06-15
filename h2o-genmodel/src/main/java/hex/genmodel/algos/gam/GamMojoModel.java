package hex.genmodel.algos.gam;

// this class takes care of all families except multinomial and ordinal
public class GamMojoModel extends GamMojoModelBase {
    String _link;
    double _tweedieLinkPower;
    private boolean _binomial;
    
    GamMojoModel(String[] columns, String[][] domains, String responseColumn) {
        super(columns, domains, responseColumn);
    }

    @Override
    void init() {
        _binomial = _family.equals("binomial");
    }
    
    @Override
    double[] gamScore0(double[] data, double[] preds) {
        return new double[0];
    }

}
