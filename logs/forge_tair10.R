suppressMessages({library(BSgenome); library(Biobase)})
seedfile <- "/home/xi/tmp/plant_m6A_data/ref/TAIR10_seed"
destdir  <- "/home/xi/tmp/plant_m6A_data/ref/bsgenome_build"
seqs_srcdir <- "/home/xi/tmp/plant_m6A_data/ref/bsgenome_src"
verbose <- FALSE

y <- as.list(BSgenome:::.readSeedFile(seedfile, verbose = verbose))  # .readSeedFile
y <- y[!(names(y) %in% "seqs_srcdir")]
x <- BSgenome:::BSgenomeDataPkgSeed(y)

template_path <- system.file("pkgtemplates", "BSgenome_datapkg", package = "BSgenome")
BSgenome_version <- installed.packages()["BSgenome", "Version"]
if (is.na(x@genome)) { x@genome <- x@provider_version }
.seqnames <- eval(parse(text = x@seqnames))
.circ_seqs <- eval(parse(text = x@circ_seqs))
symvals <- list(PKGTITLE=x@Title, PKGDESCRIPTION=x@Description, PKGVERSION=x@Version,
  AUTHOR=x@Author, MAINTAINER=x@Maintainer, BSGENOMEVERSION=BSgenome_version,
  SUGGESTS=x@Suggests, LICENSE=x@License, ORGANISM=x@organism,
  COMMONNAME=x@common_name, GENOME=x@genome, PROVIDER=x@provider,
  RELEASEDATE=x@release_date, SOURCEURL=x@source_url,
  ORGANISMBIOCVIEW=x@organism_biocview, BSGENOMEOBJNAME=x@BSgenomeObjname,
  SEQNAMES=deparse1(.seqnames), CIRCSEQS=deparse1(.circ_seqs),
  MSEQNAMES=x@mseqnames, PKGDETAILS=x@PkgDetails, SRCDATAFILES=x@SrcDataFiles,
  PKGEXAMPLES=x@PkgExamples)
pkgdir <- file.path(destdir, x@Package)
if (file.exists(pkgdir)) unlink(pkgdir, recursive = TRUE)
Biobase::createPackage(x@Package, destdir, template_path, symvals)

## ---- create the missing extdata dir (THE FIX) ----
.mseqnames <- eval(parse(text = x@mseqnames))
seqs_destdir <- file.path(pkgdir, "inst", "extdata")
dir.create(seqs_destdir, recursive = TRUE, showWarnings = FALSE)

BSgenome:::forgeSeqFiles(x@provider, x@genome, .seqnames, mseqnames = .mseqnames,
  seqfile_name = x@seqfile_name, prefix = x@seqfiles_prefix,
  suffix = x@seqfiles_suffix, seqs_srcdir = seqs_srcdir,
  seqs_destdir = seqs_destdir, ondisk_seq_format = x@ondisk_seq_format,
  verbose = verbose)

cat("MANUAL FORGE DONE\n")
cat("inst/extdata:", list.files(seqs_destdir), "\n")
