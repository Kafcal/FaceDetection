import matlab.engine

eng = matlab.engine.start_matlab()
eng.FeatureExtraction(nargout=0)
