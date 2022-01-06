
@def title = "ICON registration"
@def hascode = true
@def rss = "An exploration of inverse consistency for driving image registration"
@def rss_title = "ICON registration"
@def rss_pubdate = Date(2021, 1, 5)

@def tags = ["syntax", "code", "image"]






# ICON: Learning Regular Maps through Inverse Consistency
\fig{/assets/ICON/Intro.png}



**ICON: Learning Regular Maps through Inverse Consistency.**   
Hastings Greer, Roland Kwitt, Francois-Xavier Vialard, Marc Niethammer.  
_ICCV 2021_ https://arxiv.org/abs/2105.04459

## Cite this work
```
@InProceedings{Greer_2021_ICCV,
    author    = {Greer, Hastings and Kwitt, Roland and Vialard, Francois-Xavier and Niethammer, Marc},
    title     = {ICON: Learning Regular Maps Through Inverse Consistency},
    booktitle = {Proceedings of the IEEE/CVF International Conference on Computer Vision (ICCV)},
    month     = {October},
    year      = {2021},
    pages     = {3396-3405}
}
```

## Video Presentation

[<img src="https://img.youtube.com/vi/7kZsJ3zWDCA/maxresdefault.jpg" width="50%">](https://youtu.be/7kZsJ3zWDCA)


## Running our code

We are available on PyPI!
```bash
pip install icon-registration
```

To run our pretrained model in the cloud on 4 sample image pairs from OAI knees (as above), visit [our google colab notebook](https://colab.research.google.com/drive/1Pd3ua_NZTem3xtBvDxertzi7u3E233ZL?usp=sharing)

----------------

To train from scratch on the synthetic triangles and circles dataset:

```bash
git clone https://github.com/uncbiag/ICON
cd ICON

pip install -e .

python training_scripts/2d_triangles_example.py
```



