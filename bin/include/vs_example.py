import vapoursynth as vs
core = vs.core

def example_wrapper(src, args):
    video = core.resize.Spline36(src, width=args[0], height=args[1], format=vs.YUV420P8)
    return video
